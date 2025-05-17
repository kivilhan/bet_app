//
//  SetupDisplayNameView.swift
//  Guessio
//
//  Created by Ilhan on 14/05/2025.
//

import SwiftUI

struct SetupDisplayNameView: View {
    @State private var name = ""
    @EnvironmentObject var appManager: AppManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a Display Name")
                .font(.title)
                .padding()

            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Save") {
                Task {
                    try? await appManager.updateDisplayName(to: name)
                }
            }
            .padding()
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}
