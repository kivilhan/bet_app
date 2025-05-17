import Foundation

final class StoreViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var purchaseStatus: String? = nil

    func purchase(amount: Int, userId: String) async {
        purchaseStatus = nil
        let success = await AppManager.shared.addBetbucks(to: userId, amount: amount)
        purchaseStatus = success ? "Purchase successful!" : "Purchase failed to credit betbucks."
    }
}
