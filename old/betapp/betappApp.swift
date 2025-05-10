//
//  swKingApp.swift
//  swKing
//
//  Created by Ilhan on 20/11/2024.
//

import SwiftUI
import FirebaseCore

@main
struct betappApp: App {
    @StateObject private var userManager = UserManager()
    @StateObject private var betManager = BetManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(userManager)
                .environmentObject(betManager)
        }
    }
}
