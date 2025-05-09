//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var betManager = BetManager()

    var body: some View {
        TabView {
            PlayView()
                .tabItem {
                    Label("Play", systemImage: "gamecontroller")
                }

            WalletView()
                .tabItem {
                    Label("Wallet", systemImage: "creditcard")
                }

            BurnView()
                .tabItem {
                    Label("Burn", systemImage: "flame")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .environmentObject(userManager)
        .environmentObject(betManager)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
