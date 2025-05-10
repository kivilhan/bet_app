//
//  UserManager.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation

@MainActor
final class UserManager: ObservableObject {
    @Published private(set) var currentUser: User?

    init() {
        Task {
            await loadUser()
        }
    }

    func loadUser() async {
        // TODO: Replace with Firestore or secure storage
        if var user = await fetchUserFromBackend() {
            currentUser = user
        } else {
            let newUser = User(
                id: UUID().uuidString,
                username: "guest",
                betbucks: 1000,
                totalBurned: 0
            )
            currentUser = newUser
            await saveUserToBackend(newUser)
        }
    }

    func burnBetbucks(_ amount: Int) async -> Bool {
        guard var user = currentUser, user.betbucks >= amount else { return false }
        user.betbucks -= amount
        user.totalBurned += amount
        currentUser = user
        await saveUserToBackend(user)
        return true
    }

    private func fetchUserFromBackend() async -> User? {
        // Simulate async fetch from Firestore or local DB
        return nil
    }

    private func saveUserToBackend(_ user: User) async {
        // Simulate async save
    }
}

