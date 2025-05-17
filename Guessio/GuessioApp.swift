import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct GuessioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var appManager = AppManager()

    init() {
        FirebaseApp.configure()
#if DEBUG
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings

        //        Auth.auth().useEmulator(withHost:"localhost", port:9099)
#endif
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .fullScreenCover(isPresented: .constant(appManager.authState == .unauthenticated)) {
                    AuthView()
                        .environmentObject(AuthViewModel())
                }
                .fullScreenCover(isPresented: .constant(appManager.guessioUser?.initialized == false)) {
                    SetupDisplayNameView()
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppManager.shared) // ✅ Use the singleton instance
}
