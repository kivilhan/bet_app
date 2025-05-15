//
//  DummyBets.swift
//  betapp
//
//  Created by Ilhan on 07/05/2025.
//

import Foundation
import FirebaseFirestore

struct DummyBets {
    static let sampleEvents: [Event] = [
        Event(
            title: "Who will win the next World Cup?",
            createdById: "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3",
            options: ["Brazil", "France", "Argentina", "Germany"]
        ),
        Event(
            title: "Will it rain in London tomorrow?",
            createdById: "eefce2f5-3c82-4036-9ff8-24496cf7759d",
            options: ["Yes", "No"]
        ),
        Event(
            title: "Who will win the NBA Finals?",
            createdById: "3346c053-df38-4d5a-a297-4b6a6c9c20e0",
            options: ["Celtics", "Warriors", "Lakers"]
        )
    ]

    static let sampleBets: [Bet] = [
        // Event 1
        Bet(userId: "eefce2f5-3c82-4036-9ff8-24496cf7759d", eventId: sampleEvents[0].id, option: "Brazil", amount: 100),
        Bet(userId: "3346c053-df38-4d5a-a297-4b6a6c9c20e0", eventId: sampleEvents[0].id, option: "Germany", amount: 300),

        // Event 2
        Bet(userId: "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3", eventId: sampleEvents[1].id, option: "Yes", amount: 200),

        // Event 3
        Bet(userId: "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3", eventId: sampleEvents[2].id, option: "Warriors", amount: 150),
        Bet(userId: "eefce2f5-3c82-4036-9ff8-24496cf7759d", eventId: sampleEvents[2].id, option: "Lakers", amount: 250)
    ]


    static func uploadAllToFirestore() async throws {
        let db = Firestore.firestore()

        for event in sampleEvents {
            try await db.collection("events").document(event.id).setData(event.asDictionary)
        }

        for bet in sampleBets {
            try await db.collection("bets").document(bet.id).setData(bet.asDictionary)
        }
    }
}
