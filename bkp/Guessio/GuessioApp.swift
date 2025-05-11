//
//  GuessioApp.swift
//  Guessio
//
//  Created by Ilhan on 10/05/2025.
//

import SwiftUI
import FirebaseCore

@main
struct GuessioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userManager = UserManager()
    @StateObject private var betManager = BetManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authViewModel)
                .environmentObject(userManager)
                .environmentObject(betManager)
                .fullScreenCover(isPresented: .constant(!authViewModel.isAuthenticated)) {
                    AuthView()
                        .environmentObject(authViewModel)
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserManager())
        .environmentObject(BetManager())
}
