import Foundation

final class EventViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchEvents() async {
        isLoading = true
        errorMessage = nil
        await AppManager.shared.fetchEvents()
        isLoading = false
    }
}
