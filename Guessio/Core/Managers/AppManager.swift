import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import FBSDKLoginKit
import StoreKit

@MainActor
final class AppManager: NSObject, ObservableObject {
    static let shared = AppManager()

    let db = Firestore.firestore()

    private var userListener: ListenerRegistration?
    private var currentNonce: String?

    @Published private(set) var authState: AuthState = .unauthenticated
    @Published private(set) var firebaseUser: User?
    @Published private(set) var guessioUser: GuessioUser?
    @Published var events: [Event] = []
    @Published var products: [Product] = []

    let productIDs: [String] = [
        "com.simpleware.guessio.betbucks.100",
        "com.simpleware.guessio.betbucks.500",
        "com.simpleware.guessio.betbucks.1000"
    ]
    private var appleLoginContinuation: CheckedContinuation<AuthDataResult, Error>?

    override init() {
        super.init()
        Task {
            await monitorAuthState()
        }
    }
}

// MARK: - Auth
extension AppManager {
    private func monitorAuthState() async {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.firebaseUser = user
                self?.authState = user == nil ? .unauthenticated : .authenticated

                guard let user = user else {
                    self?.guessioUser = nil
                    return
                }

                do {
                    try await self?.checkOrCreateUserDocument(for: user)
                } catch {
                    print("Failed to fetch or create user document: \(error)")
                }
            }
        }

        // Also check on init in case the listener is delayed
        let currentUser = Auth.auth().currentUser
        self.firebaseUser = currentUser
        self.authState = currentUser == nil ? .unauthenticated : .authenticated

        if let currentUser {
            do {
                try await checkOrCreateUserDocument(for: currentUser)
            } catch {
                print("Failed to fetch or create user document on init: \(error)")
            }
        } else {
            self.guessioUser = nil
        }
    }

    // MARK: - Facebook Login
    func loginWithFacebook(from viewController: UIViewController) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let accessToken = AccessToken.current?.tokenString
                else {
                    continuation.resume(throwing: NSError(domain: "FacebookLogin", code: 0, userInfo: [NSLocalizedDescriptionKey: "No Facebook access token."]))
                    return
                }

                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let result = result {
                        continuation.resume(returning: result)
                    }
                }
            }
        }
    }

    // MARK: - Google Login
    func loginWithGoogle(from viewController: UIViewController) async throws -> AuthDataResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "GoogleLogin", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing Google Client ID."])
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)

        guard
            let idToken = result.user.idToken?.tokenString
        else {
            throw NSError(domain: "GoogleLogin", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing Google tokens."])
        }

        let accessToken = result.user.accessToken.tokenString

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return try await Auth.auth().signIn(with: credential)
    }

    // MARK: - Apple Login
    func loginWithApple() async throws -> AuthDataResult {
        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        return try await withCheckedThrowingContinuation { continuation in
            self.appleLoginContinuation = continuation
            controller.performRequests()
        }
    }

    // MARK: - Internal Apple Continuation

    // MARK: - Sign Out
    func signOut() async throws {
        try Auth.auth().signOut()
        self.firebaseUser = nil
        self.authState = .unauthenticated
    }
}

// MARK: - Apple Sign In Delegates
extension AppManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = appleIDCredential.identityToken,
              let tokenString = String(data: tokenData, encoding: .utf8),
              let nonce = currentNonce
        else {
            appleLoginContinuation?.resume(throwing: NSError(domain: "AppleLogin", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing token or nonce."]))
            return
        }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: tokenString,
            rawNonce: nonce
        )

        Task {
            do {
                let result = try await Auth.auth().signIn(with: credential)
                appleLoginContinuation?.resume(returning: result)
            } catch {
                appleLoginContinuation?.resume(throwing: error)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleLoginContinuation?.resume(throwing: error)
    }
}

// MARK: - Local User Operations
extension AppManager {
    /// Fetches the user document from Firestore or creates it if it doesn't exist.
    private func checkOrCreateUserDocument(for user: User) async throws {
        let docRef = db.collection("users").document(user.uid)

        let snapshot = try await docRef.getDocument()

        if let data = snapshot.data() {
            self.guessioUser = try Firestore.Decoder().decode(GuessioUser.self, from: data)
        } else {
            // Create a new user
            let newUser = GuessioUser(
                id: user.uid,
                username: user.displayName ?? "guest",
                lastClaimDate: nil,
                betbucks: 1000,
                totalBurned: 0,
                initialized: false
            )
            try docRef.setData(from: newUser)
            self.guessioUser = newUser
        }
    }

    func updateDisplayName(to name: String) async throws {
        guard var user = guessioUser else { return }
        user.username = name
        user.initialized = true
        user.lastClaimDate = Date()
        try await updateUserInFirestore(user)
    }

    /// Updates the current user in Firestore (and in memory).
    func updateUserInFirestore(_ updatedUser: GuessioUser) async throws {
        let docRef = Firestore.firestore().collection("users").document(updatedUser.id)
        try await docRef.setData(Firestore.Encoder().encode(updatedUser), merge: true)
        self.guessioUser = updatedUser
    }

    func startUserListener(userId: String) {
        stopUserListener()

        let userRef = db.collection("users").document(userId)
        userListener = userRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("User listener error: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No user data found.")
                return
            }

            do {
                let json = try JSONSerialization.data(withJSONObject: data)
                let user = try JSONDecoder().decode(GuessioUser.self, from: json)
                Task { @MainActor in
                    self.guessioUser = user
                }
            } catch {
                print("Failed to decode user: \(error.localizedDescription)")
            }
        }
    }

    func stopUserListener() {
        userListener?.remove()
        userListener = nil
    }

    // MARK: - Example Login Handler
    func handleLogin(for user: User) async {
        self.firebaseUser = user
        self.startUserListener(userId: user.uid)
    }

    // MARK: - Logout
    func logout() async {
        do {
            try Auth.auth().signOut()
            firebaseUser = nil
            guessioUser = nil
            stopUserListener()
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Event Operations
extension AppManager {
    func fetchEvents() async {
        do {
            let snapshot = try await db.collection("events").getDocuments()
            self.events = try snapshot.documents.compactMap { try $0.data(as: Event.self) }
        } catch {
            print("Error fetching events: \(error.localizedDescription)")
        }
    }

    func addBetbucks(to userId: String, amount: Int) async -> Bool {
        let userRef = db.collection("users").document(userId)
        do {
            try await _ = db.runTransaction { transaction, errorPointer in
                do {
                    let userDoc = try transaction.getDocument(userRef)
                    guard
                        let userData = userDoc.data(),
                        let currentBetbucks = userData["betbucks"] as? Int
                    else {
                        throw NSError(domain: "Missing user data", code: 1001)
                    }

                    transaction.updateData(["betbucks": currentBetbucks + amount], forDocument: userRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
            return true
        } catch {
            print("Error adding betbucks: \(error.localizedDescription)")
            return false
        }
    }

    func burnBetbucks(from userId: String, amount: Int) async -> Bool {
        let userRef = db.collection("users").document(userId)
        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let userDoc = try transaction.getDocument(userRef)
                    guard
                        let userData = userDoc.data(),
                        let currentBetBucks = userData["betbucks"] as? Int,
                        let totalBurned = userData["totalBurned"] as? Int
                    else {
                        throw NSError(domain: "Failed to retrieve user information.", code: 1001)
                    }

                    guard currentBetBucks >= amount else {
                        throw NSError(domain: "Not enough betbucks", code: 1002)
                    }

                    transaction.updateData([
                        "betbucks": currentBetBucks - amount,
                        "totalBurned": totalBurned + amount
                    ], forDocument: userRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
            return true
        } catch {
            print("Error burning betbucks: \(error.localizedDescription)")
            return false
        }
    }

    func placeBet(userId: String, eventId: String, option: String, amount: Int) async -> Bool {
        let userRef = db.collection("users").document(userId)
        let eventRef = db.collection("events").document(eventId)
        let betRef = eventRef.collection("bets").document(userId)

        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let userDoc = try transaction.getDocument(userRef)
                    let eventDoc = try transaction.getDocument(eventRef)

                    guard
                        let userData = userDoc.data(),
                        let eventData = eventDoc.data(),
                        let userBetbucks = userData["betbucks"] as? Int,
                        let statusRaw = eventData["status"] as? String,
                        let status = EventStatus(rawValue: statusRaw),
                        status == .takingBets
                    else {
                        throw NSError(domain: "Invalid user or event data", code: 1003)
                    }

                    guard userBetbucks >= amount else {
                        throw NSError(domain: "Insufficient betbucks", code: 1004)
                    }

                    transaction.updateData(["betbucks": userBetbucks - amount], forDocument: userRef)

                    let newBet = Bet(
                        userId: userId,
                        eventId: eventId,
                        option: option,
                        amount: amount
                    )
                    try transaction.setData(from: newBet, forDocument: betRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
            return true
        } catch {
            print("Error placing bet: \(error.localizedDescription)")
            return false
        }
    }

    func withdrawBet(userId: String, eventId: String) async -> Bool {
        let userRef = db.collection("users").document(userId)
        let eventRef = db.collection("events").document(eventId)
        let betRef = eventRef.collection("bets").document(userId)

        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let eventDoc = try transaction.getDocument(eventRef)
                    let betDoc = try transaction.getDocument(betRef)

                    guard
                        let eventData = eventDoc.data(),
                        let statusRaw = eventData["status"] as? String,
                        let status = EventStatus(rawValue: statusRaw),
                        status == .takingBets,
                        let betData = betDoc.data(),
                        let amount = betData["amount"] as? Int
                    else {
                        throw NSError(domain: "Invalid event or bet data", code: 1005)
                    }

                    transaction.updateData(["betbucks": FieldValue.increment(Int64(amount))], forDocument: userRef)
                    transaction.deleteDocument(betRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
            return true
        } catch {
            print("Error withdrawing bet: \(error.localizedDescription)")
            return false
        }
    }

    func upsertEvent(_ event: Event) async {
        do {
            try db.collection("events").document(event.id).setData(from: event)
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }

    func resolveEvent(eventId: String, winningChoice: String) async {
        let eventRef = db.collection("events").document(eventId)
        let betsRef = eventRef.collection("bets")

        do {
            let betDocs = try await betsRef.getDocuments()
            let eventDoc = try await eventRef.getDocument()
            guard let _ = try? eventDoc.data(as: Event.self) else { return }

            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    var totalPool = 0
                    var winners: [(String, Int)] = []

                    for doc in betDocs.documents {
                        let bet = try doc.data(as: Bet.self)
                        totalPool += bet.amount
                        if bet.option == winningChoice {
                            winners.append((bet.userId, bet.amount))
                        }
                    }

                    let winningsPerUser = winners.isEmpty ? 0 : totalPool / winners.count

                    for (userId, _) in winners {
                        let userRef = self.db.collection("users").document(userId)
                        transaction.updateData(["betbucks": FieldValue.increment(Int64(winningsPerUser))], forDocument: userRef)
                    }

                    transaction.updateData(["status": EventStatus.resolved.rawValue], forDocument: eventRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
        } catch {
            print("Error resolving event: \(error.localizedDescription)")
        }
    }

    func checkClaimEligibility(userId: String) async -> Bool {
        let userRef = db.collection("users").document(userId)
        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let userDoc = try transaction.getDocument(userRef)
                    guard let userData = userDoc.data() else {
                        throw NSError(domain: "Missing user data", code: 1101)
                    }

                    let now = Date()
                    let lastClaimed = (userData["lastClaimed"] as? Timestamp)?.dateValue() ?? .distantPast
                    let elapsed = now.timeIntervalSince(lastClaimed)

                    let canClaim = elapsed >= 24 * 60 * 60

                    transaction.updateData([
                        "canClaim": canClaim
                    ], forDocument: userRef)

                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }

            let snapshot = try await userRef.getDocument()
            return snapshot.data()?["canClaim"] as? Bool ?? false

        } catch {
            print("Error checking claim eligibility: \(error.localizedDescription)")
            return false
        }
    }
    func claimDailyBetbucks(userId: String, amount: Int) async -> Bool {
        let userRef = db.collection("users").document(userId)
        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let userDoc = try transaction.getDocument(userRef)
                    guard
                        let userData = userDoc.data(),
                        let canClaim = userData["canClaim"] as? Bool,
                        let betbucks = userData["betbucks"] as? Int
                    else {
                        throw NSError(domain: "Invalid user data", code: 1102)
                    }

                    guard canClaim else {
                        throw NSError(domain: "Claim not available yet", code: 1103)
                    }

                    transaction.updateData([
                        "betbucks": betbucks + amount,
                        "lastClaimed": Timestamp(date: Date()),
                        "canClaim": false
                    ], forDocument: userRef)

                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }

            return true
        } catch {
            print("Error claiming daily betbucks: \(error.localizedDescription)")
            return false
        }
    }

    func fetchLeaderboard() async -> [LeaderboardEntry] {
        var leaderboard: [LeaderboardEntry] = []
        let usersSnapshot = try? await db.collection("users").getDocuments()

        for userDoc in usersSnapshot?.documents ?? [] {
            let userId = userDoc.documentID
            let userData = userDoc.data()
            let username = userData["username"] as? String ?? "Unknown"
            let betbucks = userData["betbucks"] as? Int ?? 0

            var activeBetAmount = 0
            let eventsSnapshot = try? await db.collection("events").getDocuments()
            for eventDoc in eventsSnapshot?.documents ?? [] {
                let eventId = eventDoc.documentID
                let betSnapshot = try? await db
                    .collection("events")
                    .document(eventId)
                    .collection("bets")
                    .document(userId)
                    .getDocument()

                if let betData = betSnapshot?.data(),
                   let amount = betData["amount"] as? Int {
                    activeBetAmount += amount
                }
            }

            let total = betbucks + activeBetAmount
            leaderboard.append(LeaderboardEntry(id: userId, username: username, totalBetbucks: total))
        }

        return leaderboard.sorted { $0.totalBetbucks > $1.totalBetbucks }
    }
}
//MARK: - Store Operations
extension AppManager {
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }

    func purchase(_ product: Product) async -> Int? {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    return self.betbucksForProduct(id: product.id)
                case .unverified(_, let error):
                    print("Purchase verification failed: \(error.localizedDescription)")
                }
            case .userCancelled:
                print("User cancelled purchase")
            case .pending:
                print("Purchase pending approval")
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error.localizedDescription)")
        }
        return nil
    }

    func betbucksForProduct(id: String) -> Int {
        switch id {
        case "com.simpleware.guessio.betbucks.100": return 100
        case "com.simpleware.guessio.betbucks.500": return 500
        case "com.simpleware.guessio.betbucks.1000": return 1000
        default: return 0
        }
    }

    func startTransactionListener(userId: String) {
        Task.detached(priority: .background) {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    print("Recovered transaction: \(transaction.productID)")
                    let amount = await self.betbucksForProduct(id: transaction.productID)
                    if amount > 0 {
                        let success = await self.addBetbucks(to: userId, amount: amount)
                        if success {
                            await transaction.finish()
                            print("Delivered betbucks and finished transaction.")
                        } else {
                            print("Failed to deliver betbucks — not finishing transaction.")
                        }
                    }
                case .unverified(_, let error):
                    print("Unverified transaction update: \(error.localizedDescription)")
                }
            }
        }
    }
}
