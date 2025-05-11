//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.currentUser {
                    Text("👤 Username: \(user.username)")
                    Text("🏆 Title: \(user.rank)")
                    Text("💰 Betbucks: \(user.betbucks)")
                    Text("🔥 Total Burned: \(user.totalBurned)")
                } else {
                    ProgressView("Loading profile...")
                }

                Button(role: .destructive) {
                    Task {
                        await authViewModel.signOut()
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
        }
    }
}
