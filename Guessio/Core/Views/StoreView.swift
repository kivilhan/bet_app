// StoreView.swift
import SwiftUI

struct StoreView: View {
    @StateObject private var viewModel = StoreViewModel()

    var body: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.products, id: \.id) { product in
                Button("Buy \(product.displayName)") {
                    Task {
                        await viewModel.purchase(product: product)
                    }
                }
            }

            if let status = viewModel.purchaseStatus {
                Text(status)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.loadProducts()
            }
        }
    }
}
