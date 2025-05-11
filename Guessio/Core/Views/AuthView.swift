import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import FBSDKLoginKit

struct AuthView: View {
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Welcome to Guessio")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Apple Sign-In
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { _ in
                    Task { await AuthManager.loginWithApple() }
                }
            )
            .signInWithAppleButtonStyle(
                colorScheme == .dark ? .white : .black
            )
            .frame(height: 45)
            .cornerRadius(8)

            // Google Sign-In
            GoogleSignInButton {
                if let rootVC = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                    .first {
                    Task { await AuthManager.loginWithGoogle(from: rootVC) }
                }
            }
            .frame(height: 45)

            // Facebook Sign-In
            Button(action: {
                if let rootVC = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                    .first {
                    Task { await AuthManager.loginWithFacebook(from: rootVC) }
                }
            }) {
                HStack {
                    Image(systemName: "f.circle.fill")
                        .font(.title2)
                    Text("Continue with Facebook")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }

            Spacer()

            if let error = AuthManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

#Preview {
    AuthView()
}
