//
//  AppDelegate.swift
//  Guessio
//
//  Created by Ilhan on 10/05/2025.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FBSDKCoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Facebook SDK setup
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // Facebook + Google sign-in URL handling
        let handledByFacebook = ApplicationDelegate.shared.application(app, open: url, options: options)
        let handledByGoogle = GIDSignIn.sharedInstance.handle(url)
        return handledByFacebook || handledByGoogle
    }
}
