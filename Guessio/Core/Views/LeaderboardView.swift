import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading leaderboard...")
                } else {
                    List(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, user in
                        let user = viewModel.leaderboard[index]
                        HStack {
                            Text("#\(index + 1)")
                                .frame(width: 30, alignment: .leading)
                            Text(user.username)
                                .fontWeight(user.id == AppManager.shared.guessioUser?.id ? .bold : .regular)
                            Spacer()
                            Text("\(user.totalAssets) bb")
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)

                    if let currentUserRank = AppManager.shared.guessioUser?.leaderboardRank {
                        Text("Your Rank: #\(currentUserRank)")
                            .padding()
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .onAppear {
                Task {
                    await viewModel.fetchLeaderboard()
                }
            }
        }
    }
}
