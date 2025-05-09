//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

struct PlayView: View {
    var body: some View {
        NavigationView {
            Text("Upcoming events will be shown here.")
                .navigationTitle("Play")
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    } 
}
