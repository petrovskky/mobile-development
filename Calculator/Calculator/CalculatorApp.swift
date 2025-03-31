import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CalculatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var settings = SettingsViewModel()
    @StateObject private var passKeyManager = PassKeyManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CalculatorView()
            }
            .environmentObject(settings)
            .environmentObject(passKeyManager)
            .task {
                await settings.loadTheme()
            }
        }
    }
}
