import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView("Signing in...")
            } else {
                Button("Sign in with Apple") {
                    Task {
                        await viewModel.signInWithApple()
                    }
                }

                Button("Sign in with Google") {
                    Task {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first,
                           let rootVC = window.rootViewController {
                            await viewModel.signInWithGoogle(presentingVC: rootVC)
                        }
                    }
                }

                Button("Sign in with Facebook") {
                    Task {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = scene.windows.first,
                           let rootVC = window.rootViewController {
                            await viewModel.signInWithFacebook(presentingVC: rootVC)
                        }

                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}
