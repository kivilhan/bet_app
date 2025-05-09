//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = userManager.currentUser {
                    Text("👤 Username: \(user.username)")
                    Text("🏆 Title: \(user.rank)")
                    Text("💰 Betbucks: \(user.betbucks)")
                    Text("🔥 Total Burned: \(user.totalBurned)")
                } else {
                    ProgressView("Loading profile...")
                }
            }
            .navigationTitle("Profile")
        }
    }
}
