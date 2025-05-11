import SwiftUI
import AuthenticationServices  // for SignInWithAppleButton
import Firebase               // if needed for Firebase types

@MainActor
class AuthViewModel: ObservableObject {
    // Published properties to drive UI state
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let authManager = AuthManager.shared  // reference to the AuthManager (could also be injected)

    /// Initiates Sign in with Apple flow
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        do {
            try await _ = authManager.loginWithApple()
            // On success, AuthManager.authState and user info are updated internally
        } catch {
            // Capture error to show in the UI
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Initiates Sign in with Google flow
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        do {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                try await _ = authManager.loginWithGoogle(from: rootVC)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Initiates Sign in with Facebook flow
    func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil
        do {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                try await _ = authManager.loginWithFacebook(from: rootVC)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
