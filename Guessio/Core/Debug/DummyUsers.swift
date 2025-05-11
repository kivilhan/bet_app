//
//  DummyUsers.swift
//  betapp
//
//  Created by Ilhan on 07/05/2025.
//

import Foundation

struct DummyUsers {
    static let sampleUsers: [String: [String: Any]] = [
        "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3": [
            "id": "d11223ba-5c4e-4a1e-b1b6-f89d781ee5a3",
            "username": "alexj",
            "joinDate": Date().addingTimeInterval(-86400 * 30), // joined 30 days ago
            "totalBetbucks": 1200
        ],
        "eefce2f5-3c82-4036-9ff8-24496cf7759d": [
            "id": "eefce2f5-3c82-4036-9ff8-24496cf7759d",
            "username": "jamielee",
            "joinDate": Date().addingTimeInterval(-86400 * 15), // joined 15 days ago
            "totalBetbucks": 300
        ],
        "3346c053-df38-4d5a-a297-4b6a6c9c20e0": [
            "id": "3346c053-df38-4d5a-a297-4b6a6c9c20e0",
            "username": "samriv",
            "joinDate": Date().addingTimeInterval(-86400 * 60), // joined 60 days ago
            "totalBetbucks": 5000
        ]
    ]
}
