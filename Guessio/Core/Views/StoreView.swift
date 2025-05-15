//
//  StoreView.swift
//  Guessio
//
//  Created by Ilhan on 15/05/2025.
//


import SwiftUI
import StoreKit

struct StoreView: View {
    @StateObject private var viewModel = StoreViewModel()
    @AppStorage("userId") var userId: String = ""  // Replace with your actual user ID source

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading store...")
                } else {
                    List(viewModel.products, id: \.id) { product in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(product.displayName)
                                    .font(.headline)
                                Text(product.description)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Button(product.displayPrice) {
                                Task {
                                    await viewModel.purchase(product: product, userId: userId)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 8)
                    }
                }

                if let status = viewModel.purchaseStatus {
                    Text(status)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Buy Betbucks")
            .task {
                await viewModel.loadProducts()
            }
        }
    }
}

#Preview {
    StoreView()
}
