//
//  MainTabView.swift
//  betapp
//
//  Created by Ilhan on 19/04/2025.
//

import SwiftUI

let sampleBets: [Bet] = DummyBets.sampleBets

struct PlayView: View {
    @StateObject private var betManager = BetManager()

    var body: some View {
        let sortedBets = sampleBets.sorted { $0.potSize > $1.potSize }

        NavigationView {
            List(sortedBets) { bet in
                VStack(alignment: .leading, spacing: 4) {
                    Text(bet.title)
                        .font(.headline)
                    Text("Pot: \(bet.potSize) BB")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Play")
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    } 
}
