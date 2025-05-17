import Foundation

final class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: [GuessioUser] = []
    @Published var isLoading = false


    func fetchLeaderboard() async {
        isLoading = true
        Task {
            let result = await AppManager.shared.retrieveLeaderboard()
            await MainActor.run {
                leaderboard = result
                isLoading = false
            }
        }
    }
}
