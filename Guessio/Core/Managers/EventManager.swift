import Foundation
import FirebaseFirestore

@MainActor
class EventManager: ObservableObject {
    private let db = Firestore.firestore()
    static let shared = EventManager()
    @Published var events: [Event] = []

    // MARK: - Fetch Events
    func fetchEvents() async {
        do {
            let snapshot = try await db.collection("events").getDocuments()
            self.events = try snapshot.documents.compactMap { try $0.data(as: Event.self) }
        } catch {
            print("Error fetching events: \(error.localizedDescription)")
        }
    }

    // MARK: - Add Betbucks
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


    // MARK: - Burn Betbucks
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

    // MARK: - Place Bet
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

    // MARK: - Withdraw Bet
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

    // MARK: - Create or Update Event
    func upsertEvent(_ event: Event) async {
        do {
            try db.collection("events").document(event.id).setData(from: event)
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }

    // MARK: - Resolve Event
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

    //MARK: - Check Claim Eligibility
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
    //MARK: - Claim Daily Betbucks
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

}

