//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

struct WalletView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.guessioUser {
                    Text("💰 Betbucks: \(user.betbucks)")
                        .font(.title)

                    Button("Buy 100 Betbucks ($1)") {
                        // TODO: Trigger StoreManager
                    }

                    Button("Buy 500 Betbucks ($4)") {
                        // TODO: Trigger StoreManager
                    }

                    Button("Buy 1000 Betbucks ($7)") {
                        // TODO: Trigger StoreManager
                    }
                } else {
                    ProgressView("Loading user...")
                }
            }
            .navigationTitle("Wallet")
        }
    }
}
