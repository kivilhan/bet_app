//
//  AuthViewModel.swift
//  Guessio
//
//  Created by Ilhan on 10/05/2025.
//

import Foundation
import FirebaseAuth
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let auth = Auth.auth()

    init() {
        self.user = auth.currentUser
        self.isAuthenticated = (user != nil)
    }

    // MARK: - Apple Sign-In
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await AuthManager.shared.loginWithApple()
            user = result.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Google Sign-In
    func signInWithGoogle(from viewController: UIViewController) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await AuthManager.shared.loginWithGoogle(from: viewController)
            user = result.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Facebook Sign-In
    func signInWithFacebook(from viewController: UIViewController) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await AuthManager.shared.loginWithFacebook(from: viewController)
            user = result.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try auth.signOut()
            user = nil
            isAuthenticated = false
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
}
