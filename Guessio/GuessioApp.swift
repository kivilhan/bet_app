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

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = AppManager()
        mockManager.authState = .authenticated
        mockManager.guessioUser = GuessioUser(
            id: "mock-id",
            username: "MockUser",
            lastClaimDate: Date(),
            betbucks: 1200,
            totalAssets: 1700,
            leaderboardRank: 10,
            initialized: true
        )

        return MainTabView()
            .environmentObject(mockManager)
    }
}
