import SwiftData
import SwiftUI

@main
struct VellumPadApp: App {
    private let container: ModelContainer

    init() {
        let schema = Schema([Page.self])
        let configuration = ModelConfiguration("vellum-pages", schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
        SamplePages.seedIfNeeded(in: container)
    }

    var body: some Scene {
        WindowGroup {
            LibraryView()
        }
        .modelContainer(container)
    }
}
