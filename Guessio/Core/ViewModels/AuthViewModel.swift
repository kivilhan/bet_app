import Foundation
import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            try await _ = AppManager.shared.loginWithApple()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithGoogle(presentingVC: UIViewController) async {
        isLoading = true
        errorMessage = nil
        do {
            try await _ = AppManager.shared.loginWithGoogle(from: presentingVC)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithFacebook(presentingVC: UIViewController) async {
        isLoading = true
        errorMessage = nil
        do {
            try await _ = AppManager.shared.loginWithFacebook(from: presentingVC)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
