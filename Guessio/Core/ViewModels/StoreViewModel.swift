import Foundation
import StoreKit

@MainActor
class StoreViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var purchaseStatus: String?

    private let storeManager = StoreManager.shared
    private let eventManager = EventManager.shared

    func loadProducts() async {
        isLoading = true
        await storeManager.loadProducts()
        products = storeManager.products
        isLoading = false
    }

    func purchase(product: Product, userId: String) async {
        purchaseStatus = nil
        if let betbucks = await storeManager.purchase(product) {
            let success = await eventManager.addBetbucks(to: userId, amount: betbucks)
            purchaseStatus = success ? "Purchase successful!" : "Purchase failed to credit betbucks."
        } else {
            purchaseStatus = "Purchase was not completed."
        }
    }
}
