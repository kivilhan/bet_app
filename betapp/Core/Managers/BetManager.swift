//
//  BetManager.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation

@MainActor
final class BetManager: ObservableObject {
    @Published private(set) var allBets: [Bet] = []

    func placeBet(userId: String, eventId: String, optionId: String, amount: Int) async {
        let newBet = Bet(
            id: UUID().uuidString,
            userId: userId,
            eventId: eventId,
            optionId: optionId,
            amount: amount,
            timestamp: Date()
        )
        allBets.append(newBet)
    }

    func getBetsForEvent(for eventId: String) async -> [Bet] {
        return allBets.filter { $0.eventId == eventId }
    }

    func getBetsForUser(for userId: String) async -> [Bet] {
        return allBets.filter { $0.userId == userId }
    }
}
