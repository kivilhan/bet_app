//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

struct BurnView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var amountToBurn = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authManager.guessioUser {
                    Text("🔥 Burned: \(user.totalBurned )")
                    Text("🏆 Title: \(user.rank)")

                    TextField("Amount to burn", text: $amountToBurn)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Burn") {
                        Task {
                            if let amount = Int(amountToBurn) {
                                do {
                                    try await authManager.burnBetbucks(amount)
                                } catch {
                                    print("Failed to burn betbucks: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                } else {
                    ProgressView("Loading user...")
                }
            }
            .padding()
            .navigationTitle("Burn")
        }
    }
}
