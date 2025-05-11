import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import FBSDKLoginKit
import CryptoKit
import UIKit

@MainActor
final class AuthManager: NSObject, ObservableObject {
    let db = Firestore.firestore()
    static let shared = AuthManager()
    private var currentNonce: String?
    @Published private(set) var authState: AuthState = .unauthenticated
    @Published private(set) var firebaseUser: User?
    @Published private(set) var guessioUser: GuessioUser?

    override init() {
        super.init()
        Task {
            await monitorAuthState()
        }
    }

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
    private var appleLoginContinuation: CheckedContinuation<AuthDataResult, Error>?

    // MARK: - Sign Out
    func signOut() async throws {
        try Auth.auth().signOut()
        self.firebaseUser = nil
        self.authState = .unauthenticated
    }
}

// MARK: - Apple Sign In Delegates
extension AuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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

extension AuthManager {
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
                totalBurned: 0
            )
            try docRef.setData(from: newUser)
            self.guessioUser = newUser
        }
    }

    /// Updates the current user in Firestore (and in memory).
    func updateUserInFirestore(_ updatedUser: GuessioUser) async throws {
        let docRef = Firestore.firestore().collection("users").document(updatedUser.id)
        try await docRef.setData(Firestore.Encoder().encode(updatedUser), merge: true)
        self.guessioUser = updatedUser
    }

    /// Deducts betbucks from the current user and updates Firestore.
    func burnBetbucks(_ amount: Int) async throws {
        guard var user = guessioUser, user.betbucks >= amount else {
            throw NSError(domain: "Not enough betbucks", code: 1)
        }

        user.betbucks -= amount
        user.totalBurned += amount
        try await updateUserInFirestore(user)
    }
}


// MARK: - Nonce Utilities
private func randomNonceString(length: Int = 32) -> String {
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }

        for random in randoms {
            if remainingLength == 0 {
                break
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.map { String(format: "%02x", $0) }.joined()
}

enum AuthState {
    case authenticated
    case unauthenticated
}
