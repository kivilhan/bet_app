import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    // If AuthManager is an environment object tracking auth state:
    // @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // 1. Branding placeholder (e.g., app logo or name)
                Spacer()
                Image(systemName: "person.circle.fill")  // placeholder image; replace with actual logo if available
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                Text("Guessio")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 40)

                SignInWithAppleButton(.signIn,
                    onRequest: { _ in
                        // No scopes requested: no fullName, no email
                    },
                    onCompletion: { _ in
                        // This will be ignored; we handle logic with `.task`
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(8)
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                .overlay(
                    Color.clear.onTapGesture {
                        Task { await viewModel.signInWithApple() }
                    }
                )


                // 3. Sign in with Google button
                Button(action: {
                    Task { await viewModel.signInWithGoogle() }
                }) {
                    HStack {
                        Label("Sign in", systemImage: "globe")
                        Text("Sign in with Google")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .foregroundColor(.white)
                .background(Color(red: 0.22, green: 0.47, blue: 0.99))  // Google blue color
                .cornerRadius(8)
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                // 4. Sign in with Facebook button
                Button(action: {
                    Task { await viewModel.signInWithFacebook() }
                }) {
                    HStack {
                        Label("Sign in", systemImage: "globe")  // assuming you have a Facebook logo asset
                        Text("Sign in with Facebook")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .foregroundColor(.white)
                .background(Color.blue)  // Facebook brand color
                .cornerRadius(8)
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                // 5. Error message text (if any)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()  // push content to top and bottom for nicer layout
            }

            // 6. Loading indicator overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4)   // translucent overlay
                    .ignoresSafeArea()
                ProgressView("Signing in...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
