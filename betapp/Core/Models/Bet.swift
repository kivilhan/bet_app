//
//  Bet.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation

enum BetStatus: String, CaseIterable, Codable {
    case takingBets
    case betsClosed
    case resolved
    case cancelled
}

struct BetParticipant: Codable {
    let playerId: String
    let username: String
    let amount: Int
    let position: String
}

struct Bet: Identifiable, Codable {
    let id: String
    let title: String
    let status: BetStatus
    let options: [String]
    let bettingEnds: Date
    let resolvedOption: String
    let creatorName: String
    let creatorId: String
    let tags: [String]
    let participants: [BetParticipant]

    var potSize: Int {
        participants.reduce(0) { $0 + $1.amount }
    }

    init(
        id: String,
        title: String,
        status: BetStatus,
        options: [String],
        bettingEnds: Date,
        resolvedOption: String,
        creatorName: String,
        creatorId: String,
        tags: [String],
        participants: [BetParticipant]
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.options = options
        self.bettingEnds = bettingEnds
        self.resolvedOption = resolvedOption
        self.creatorName = creatorName
        self.creatorId = creatorId
        self.tags = tags
        self.participants = participants
    }
}
