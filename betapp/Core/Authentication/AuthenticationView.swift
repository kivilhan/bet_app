//
//  AuthenticationView.swift
//  swKing
//
//  Created by Ilhan on 21/11/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseAnalytics
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel

    @State private var showPassword: Bool = false
    @Environment(\.dismiss) var dismiss

    private func signInWithEmailPassword() {
        Task {
            if await viewModel.signInWithEmailPassword() == true {
                dismiss()
            }
        }
    }

    private func signUpWithEmailPassword() {
        Task {
            if await viewModel.signUpWithEmailPassword() == true {
                dismiss()
            }
        }
    }

    var body: some View {
        ZStack{
            Color(.black)
            VStack {
                HStack {
                    VStack {
                        Divider()
                            .frame(height: 1)
                            .overlay(.white.opacity(0.7))
                    }
                    Text("or")
                        .foregroundColor(.white.opacity(0.7))
                    VStack {
                        Divider()
                            .frame(height: 1)
                            .overlay(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 7)


                SignInWithAppleButton { request in
                    viewModel.handleSignInWithAppleRequest(request)
                } onCompletion: { result in
                    viewModel.handleSignInWithAppleCompletion(result)
                }
                .signInWithAppleButtonStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: 47)

                Button(action: {
                    Task {
                        if await viewModel.signInWithGoogle() == true {
                            dismiss()
                        }
                    }
                }) {
                    HStack {

                        Spacer()

                        Image("Google")
                            .resizable()
                            .frame(
                                width: 19,
                                height: 19,
                                alignment: .center
                            )
                            .padding(.horizontal, -5)

                        Text("Sign in with Google")
                            .bold()

                        Spacer()
                    }
                    .frame(height: 15)
                }


                //                Button(action: {
                //                    let tmp = Auth.auth().currentUser?.isEmailVerified
                //                    print(tmp)
                //
                //                    Task {
                //                        await sendEmailVerification()
                //                    }
                //                }) {
                //                    Text("Test Button")
                //                }
                //                .buttonStyle0()
            }
            .padding(15)

        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
}
