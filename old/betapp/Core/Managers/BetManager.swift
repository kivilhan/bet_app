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

    init() {
        loadDummyBets()
    }

    private func loadDummyBets() {
        self.allBets = DummyBets.sampleBets
    }

    func addParticipant(
        to betId: String,
        playerId: String,
        username: String,
        amount: Int,
        position: String
    ) {
        guard let index = allBets.firstIndex(where: { $0.id == betId }) else { return }

        var bet = allBets[index]
        let newParticipant = BetParticipant(
            playerId: playerId,
            username: username,
            amount: amount,
            position: position
        )
        bet.participants.append(newParticipant)
        allBets[index] = bet
    }

    func getBetsSortedByPot() -> [Bet] {
        return allBets.sorted { $0.potSize > $1.potSize }
    }

    func getBets(forUser userId: String) -> [Bet] {
        return allBets.filter { $0.creatorId == userId }
    }

    func getBet(byId id: String) -> Bet? {
        return allBets.first(where: { $0.id == id })
    }
}
