//
//  LadderRank.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

enum LadderRank: String, CaseIterable, Identifiable {
    case newbie
    case ember
    case spark
    case flame
    case inferno
    case ascended

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newbie: return "Newbie"
        case .ember: return "Ember"
        case .spark: return "Spark"
        case .flame: return "Flame"
        case .inferno: return "Inferno"
        case .ascended: return "Ascended"
        }
    }

    static func rank(for burned: Int) -> LadderRank {
        switch burned {
        case 0..<100: return .newbie
        case 100..<500: return .ember
        case 500..<1000: return .spark
        case 1000..<5000: return .flame
        case 5000..<10000: return .inferno
        default: return .ascended
        }
    }
}
