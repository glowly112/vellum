import SwiftData
import SwiftUI

@main
struct VellumPadApp: App {
    private let container: ModelContainer
    @State private var trash = PageTrash()
    @AppStorage(WelcomeLook.defaultsKey) private var welcomeSeen = false
    @AppStorage(DeskSettings.welcomeKey) private var replayWelcome = SettingsLook.welcomeDefault
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw

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
            Group {
                if showsWelcome {
                    WelcomeView {
                        WelcomeGate.finish()
                    }
                } else {
                    LibraryView()
                }
            }
            .environment(trash)
            .velinAppearance(appearanceRaw)
        }
        .modelContainer(container)
    }

    /// Welcome is the root until Skip / Done. Library is not underneath.
    private var showsWelcome: Bool {
        #if DEBUG
        if DebugOpenFirst.shouldOpenFirstPage() { return false }
        #endif
        return !welcomeSeen || replayWelcome
    }

}
