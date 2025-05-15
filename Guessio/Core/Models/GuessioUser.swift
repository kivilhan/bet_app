//
//  GuessioUser.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation

struct GuessioUser: Identifiable, Decodable, Encodable {
    let id: String
    var username: String
    var lastClaimDate: Date?
    var betbucks: Int
    var totalBurned: Int
    var rank: LadderRank {
        LadderRank.rank(for: totalBurned)
    }
    var initialized: Bool = false
}
