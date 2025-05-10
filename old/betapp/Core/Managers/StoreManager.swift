//
//  StoreManager.swift
//  betapp
//
//  Created by Ilhan on 16/04/2025.
//

import Foundation

@MainActor
final class StoreManager: ObservableObject {
    func purchaseBetbucks(amount: Int) async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate delay
        return true // Hook into StoreKit2 in production
    }
}
