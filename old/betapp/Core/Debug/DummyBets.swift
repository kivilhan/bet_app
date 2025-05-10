//
//  DummyBets.swift
//  betapp
//
//  Created by Ilhan on 07/05/2025.
//

import Foundation

let unserolvedPlaceholder: String = "unresolved"

struct DummyBets {
    static let sampleBets: [Bet] = [
        Bet(
            id: "bfa2a4c4-8726-4a38-88a2-d234a2177c99",
            title: "Who will win the next World Cup?",
            status: .takingBets,
            options: ["Brazil", "France", "Argentina", "Germany"],
            bettingEnds: Date().addingTimeInterval(3600),
            resolvedOption: "unresolved",
            creatorName: "Alex Johnson",
            creatorId: "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3",
            tags: ["sports", "football", "world cup"],
            participants: [
                BetParticipant(
                    playerId: "eefce2f5-3c82-4036-9ff8-24496cf7759d",
                    username: "jamielee",
                    amount: 100,
                    position: "Brazil"),
                BetParticipant(
                    playerId: "3346c053-df38-4d5a-a297-4b6a6c9c20e0",
                    username: "samriv",
                    amount: 300,
                    position: "Germany")
            ]
        ),
        Bet(
            id: "a7f99d94-1d26-4463-8e6c-c78e5e1984d1",
            title: "Will it rain in London tomorrow?",
            status: .betsClosed,
            options: ["Yes", "No"],
            bettingEnds: Date().addingTimeInterval(-3600),
            resolvedOption: "unresolved",
            creatorName: "Jamie Lee",
            creatorId: "eefce2f5-3c82-4036-9ff8-24496cf7759d",
            tags: ["weather", "UK", "daily"],
            participants: [
                BetParticipant(
                    playerId: "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3",
                    username: "alexj",
                    amount: 200,
                    position: "Yes")
            ]
        ),
        Bet(
            id: "e4b3d1e1-fd8a-46de-a7b0-b731edb2d9f8",
            title: "Who will win the NBA Finals?",
            status: .resolved,
            options: ["Celtics", "Warriors", "Lakers"],
            bettingEnds: Date().addingTimeInterval(-86400),
            resolvedOption: "Celtics",
            creatorName: "Sam Rivera",
            creatorId: "3346c053-df38-4d5a-a297-4b6a6c9c20e0",
            tags: ["sports", "basketball", "NBA"],
            participants: [
                BetParticipant(
                    playerId: "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3",
                    username: "alexj",
                    amount: 150,
                    position: "Warriors"),
                BetParticipant(
                    playerId: "eefce2f5-3c82-4036-9ff8-24496cf7759d",
                    username: "jamielee",
                    amount: 250,
                    position: "Lakers")
            ]
        )
    ]
}

