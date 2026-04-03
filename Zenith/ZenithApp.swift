import SwiftUI

@main
struct ZenithApp: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var appViewModel = AppViewModel.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(appViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
