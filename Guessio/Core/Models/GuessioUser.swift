import Foundation

struct GuessioUser: Identifiable, Decodable, Encodable {
    let id: String
    var username: String
    var lastClaimDate: Date
    var betbucks: Int
    var totalAssets: Int
    var leaderboardRank: Int?
    var initialized: Bool = false
}
