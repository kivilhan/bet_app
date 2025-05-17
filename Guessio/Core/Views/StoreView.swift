import SwiftUI

struct StoreView: View {
    @EnvironmentObject var app: AppManager
    @StateObject private var viewModel = StoreViewModel()

    var body: some View {
        VStack(spacing: 16) {
            ForEach(app.products, id: \.id) { product in
                Button("Buy \(product.displayName)") {
                    Task {
                        if let userId = app.firebaseUser?.uid {
                            let amount = app.betbucksForProduct(id: product.id)
                            await viewModel.purchase(amount: amount, userId: userId)
                        }
                    }
                }
            }

            if let status = viewModel.purchaseStatus {
                Text(status).foregroundColor(.blue)
            }
        }
        .onAppear {
            Task {
                await AppManager.shared.loadProducts()
            }
        }
        .padding()
    }
}
