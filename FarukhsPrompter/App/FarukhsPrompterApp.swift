import SwiftUI

@main
struct FarukhsPrompterApp: App {
    @StateObject private var store = ScriptStore()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(settings)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView {
            LibraryView()
                .tabItem { Label("Scripts", systemImage: "doc.text") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
        }
        .tint(settings.accent)
    }
}
