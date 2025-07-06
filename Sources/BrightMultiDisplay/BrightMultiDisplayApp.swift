import SwiftUI
import KeyboardShortcuts

@main
struct BrightMultiDisplayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
