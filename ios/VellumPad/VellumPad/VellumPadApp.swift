import SwiftData
import SwiftUI

@main
struct VellumPadApp: App {
    private let container: ModelContainer
    @State private var trash = PageTrash()

    init() {
        TypefaceRegistry.register()
        let schema = Schema([Page.self])
        let configuration = ModelConfiguration("vellum-pages", schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Do not fall back to an in-memory store — that hides the user's pages.
            fatalError("SwiftData container failed: \(error)")
        }
        SamplePages.seedIfNeeded(in: container)
    }

    var body: some Scene {
        WindowGroup {
            DeskRoot()
                .environment(trash)
        }
        .modelContainer(container)
    }
}

/// One gate. UserDefaults via `WelcomeGate.shouldPresent` — not drifted AppStorage copies.
private struct DeskRoot: View {
    @AppStorage(WelcomeLook.defaultsKey) private var welcomeSeen = false
    @AppStorage(DeskSettings.welcomeKey) private var replayWelcome = SettingsLook.welcomeDefault
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw

    var body: some View {
        Group {
            if WelcomeGate.shouldPresent() {
                WelcomeView(onFinished: dismissWelcome)
            } else {
                LibraryView()
            }
        }
        .velinAppearance(appearanceRaw)
    }

    /// Sync the AppStorage observers after the UserDefaults write so the root retints.
    private func dismissWelcome() {
        WelcomeGate.finish()
        welcomeSeen = true
        replayWelcome = false
    }
}
