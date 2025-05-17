// StoreViewModel.swift
import Foundation
import StoreKit

@MainActor
final class StoreViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var purchaseStatus: String? = nil
    @Published var products: [Product] = []

    private var appManager: AppManager

    init(appManager: AppManager = .shared) {
        self.appManager = appManager
    }

    var guessioUserID: String? {
        appManager.guessioUser?.id
    }

    func loadProducts() async {
        await appManager.loadProducts()
        await MainActor.run {
            self.products = appManager.products
        }
    }

    func betbucksForProduct(id: String) -> Int {
        appManager.betbucksForProduct(id: id)
    }

    func purchase(product: Product) async {
        purchaseStatus = nil
        guard let userId = guessioUserID else {
            purchaseStatus = "No user ID available."
            return
        }

        guard let amount = await appManager.purchase(product) else {
            purchaseStatus = "Purchase failed to credit betbucks."
            return
        }

        let success = await appManager.addBetbucks(to: userId, amount: amount)
        purchaseStatus = success ? "Purchase successful!" : "Purchase failed to credit betbucks."
    }
}
