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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage(WelcomeLook.defaultsKey) private var welcomeSeen = false
    @AppStorage(DeskSettings.welcomeKey) private var replayWelcome = SettingsLook.welcomeDefault
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw
    @State private var exitKind: WelcomeExit = .done

    private var presentsWelcome: Bool {
        WelcomeGate.shouldPresent()
    }

    var body: some View {
        ZStack {
            if presentsWelcome {
                WelcomeView(onFinished: dismissWelcome)
                    .transition(welcomeTransition)
            } else {
                LibraryView()
                    .transition(libraryTransition)
            }
        }
        .animation(rootMotion, value: presentsWelcome)
        .velinAppearance(appearanceRaw)
    }

    private var rootMotion: Animation? {
        if reduceMotion || WelcomeLook.exitIsCut { return nil }
        switch exitKind {
        case .skip:
            return .spring(response: 0.28, dampingFraction: 0.90)
        case .done:
            return .spring(
                response: DeskMotion.response,
                dampingFraction: DeskMotion.damping
            )
        }
    }

    private var welcomeTransition: AnyTransition {
        if reduceMotion { return .opacity }
        if exitKind == .skip {
            return .asymmetric(
                insertion: .identity,
                removal: .opacity.combined(with: .scale(scale: 0.98))
            )
        }
        return .asymmetric(
            insertion: .identity,
            removal: .modifier(
                active: WelcomeTurn(progress: -1),
                identity: WelcomeTurn(progress: 0)
            )
        )
    }

    private var libraryTransition: AnyTransition {
        if reduceMotion { return .opacity }
        if exitKind == .skip {
            return .opacity.combined(with: .scale(scale: 0.98))
        }
        return .asymmetric(
            insertion: .modifier(
                active: WelcomeTurn(progress: 1),
                identity: WelcomeTurn(progress: 0)
            ),
            removal: .identity
        )
    }

    /// Write the gate inside the spring so the root turns — not a swap snap.
    private func dismissWelcome(_ exit: WelcomeExit) {
        exitKind = exit
        withAnimation(rootMotion) {
            WelcomeGate.finish()
            welcomeSeen = true
            replayWelcome = false
        }
    }
}
