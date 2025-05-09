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
}

struct Bet: Identifiable, Codable {
    let id: String
    let title: String
    let status: EventStatus
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

    // Optional convenience initializer from [String: Any]
    init?(from dict: [String: Any]) {
        guard
            let id = dict["id"] as? String,
            let title = dict["title"] as? String,
            let statusRaw = dict["status"] as? String,
            let status = EventStatus(rawValue: statusRaw),
            let options = dict["options"] as? [String],
            let bettingEnds = dict["bettingEnds"] as? Date,
            let resolvedOption = dict["resolvedOption"] as? String,
            let creatorName = dict["creatorName"] as? String,
            let creatorId = dict["creatorId"] as? String,
            let tags = dict["tags"] as? [String],
            let participantDicts = dict["participants"] as? [[String: Any]]
        else {
            return nil
        }

        let participants = participantDicts.compactMap { entry -> BetParticipant? in
            guard
                let playerId = entry["playerId"] as? String,
                let username = entry["username"] as? String,
                let amount = entry["amount"] as? Int
            else {
                return nil
            }
            return BetParticipant(playerId: playerId, username: username, amount: amount)
        }

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

