import Foundation

struct Bet: Identifiable, Codable {
    let id: String
    let userId: String         // The user placing the bet
    let eventId: String        // The event this bet is for
    let option: String
    let amount: Int            // Number of betbucks wagered
    let placedAt: Date
    var isWinningBet: Bool?    // nil until event is resolved

    init(
        userId: String,
        eventId: String,
        option: String,
        amount: Int,
        placedAt: Date = Date()
    ) {
        self.id = UUID().uuidString
        self.userId = userId
        self.eventId = eventId
        self.option = option
        self.amount = amount
        self.placedAt = placedAt
        self.isWinningBet = nil
    }

    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "eventId": eventId,
            "option": option,
            "amount": amount,
            "placedAt": placedAt
        ]

        if let isWinningBet = isWinningBet {
            dict["isWinningBet"] = isWinningBet
        }

        return dict
    }
}
