//
//  GuessioApp.swift
//  Guessio
//
//  Created by Ilhan on 10/05/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct GuessioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var authManager = AuthManager()
    @StateObject private var eventManager = EventManager()

    init() {
        FirebaseApp.configure()
#if DEBUG
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings

        //        Auth.auth().useEmulator(withHost:"localhost", port:9099)
#endif
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authViewModel)
                .environmentObject(authManager)
                .environmentObject(eventManager)
                .fullScreenCover(isPresented: .constant(authManager.authState == .unauthenticated)) {
                    AuthView()
                        .environmentObject(authViewModel)
                }
                .fullScreenCover(isPresented: .constant(authManager.guessioUser?.initialized == false)) {
                    SetupDisplayNameView()
                }
        }
    }
}
