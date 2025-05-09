//
//  User.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation

struct User: Identifiable {
    var id: String
    var username: String
    var betbucks: Int
    var lastClaimDate: Date?
    var totalBurned: Int
    var rank: LadderRank {
        LadderRank.rank(for: totalBurned)
    }
}

