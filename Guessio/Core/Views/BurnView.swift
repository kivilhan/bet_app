import SwiftUI

struct BurnView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var amountToBurn = ""
    @State private var burnStatus: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = appManager.guessioUser {
                    Text("🔥 Burned: \(user.totalBurned)")
                    Text("🏆 Title: \(user.rank)")

                    TextField("Amount to burn", text: $amountToBurn)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Burn") {
                        Task {
                            guard let amount = Int(amountToBurn),
                                  let userId = appManager.firebaseUser?.uid else {
                                burnStatus = "Invalid input or user not loaded."
                                return
                            }

                            let success = await appManager.burnBetbucks(from: userId, amount: amount)
                            burnStatus = success ? "🔥 Burned \(amount) betbucks!" : "⚠️ Could not burn betbucks."

                            amountToBurn = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    if let burnStatus {
                        Text(burnStatus)
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
