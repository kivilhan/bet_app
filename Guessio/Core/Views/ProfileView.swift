//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = appManager.guessioUser {
                    Text("👤 Username: \(user.username)")
                    Text(
                        "🏆 Title: \(String(describing: user.leaderboardRank))"
                    )
                    Text("💰 Betbucks: \(user.betbucks)")
                } else {
                    ProgressView("Loading profile...")
                }

                Button(role: .destructive) {
                    Task {    do {
                        try await appManager.signOut()
                    } catch {
                        print("Sign-out failed: \(error.localizedDescription)")
                        // Optionally show an error message in the UI
                    }
                    }
                } label: {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Profile")
            .overlay(firebaseAndGuessioUserOverlay)
        }
    }
    private var firebaseAndGuessioUserOverlay: some View {
        // paste the VStack block here
        VStack(alignment: .leading, spacing: 8) {
            // Firebase User Info
            Text("🔥 Firebase User:")
                .font(.headline)
            if let firebaseUser = appManager.firebaseUser {
                Text("UID: \(firebaseUser.uid)")
                Text("Email: \(firebaseUser.email ?? "nil")")
                Text("Display Name: \(firebaseUser.displayName ?? "nil")")
                Text("Is Anonymous: \(firebaseUser.isAnonymous.description)")
            } else {
                Text("Not signed in")
            }

            Divider()

            // Guessio User Info
            Text("🎯 Guessio User:")
                .font(.headline)
            if let guessioUser = appManager.guessioUser {
                Text("ID: \(guessioUser.id)")
                Text("Username: \(guessioUser.username)")
                Text("Betbucks: \(guessioUser.betbucks)")
                Text("Last Claim: \(guessioUser.lastClaimDate)")
            } else {
                Text("No Guessio user loaded")
            }
        }
    }
}
