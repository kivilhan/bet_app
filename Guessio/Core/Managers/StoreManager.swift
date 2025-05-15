import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []

    private init() {}

    let productIDs: [String] = [
        "com.simpleware.guessio.betbucks.100",
        "com.simpleware.guessio.betbucks.500",
        "com.simpleware.guessio.betbucks.1000"
    ]

    // Load products from App Store
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }

    // Purchase a product and return how many betbucks to add
    func purchase(_ product: Product) async -> Int? {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    return self.betbucksForProduct(id: product.id)
                case .unverified(_, let error):
                    print("Purchase verification failed: \(error.localizedDescription)")
                }
            case .userCancelled:
                print("User cancelled purchase")
            case .pending:
                print("Purchase pending approval")
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error.localizedDescription)")
        }
        return nil
    }

    private func betbucksForProduct(id: String) -> Int {
        switch id {
        case "com.simpleware.guessio.betbucks.100": return 100
        case "com.simpleware.guessio.betbucks.500": return 500
        case "com.simpleware.guessio.betbucks.1000": return 1000
        default: return 0
        }
    }
}
