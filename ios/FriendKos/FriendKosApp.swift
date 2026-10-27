import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure() // membaca GoogleService-Info.plist
        return true
    }
}

@main
struct FriendKosApp: App {
    // Mendaftarkan app delegate untuk setup Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .onOpenURL { GIDSignIn.sharedInstance.handle($0) }
        }
    }
}
