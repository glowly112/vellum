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
            LibraryView()
                .environment(trash)
        }
        .modelContainer(container)
    }
}
