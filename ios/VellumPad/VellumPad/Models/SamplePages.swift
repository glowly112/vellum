import Foundation
import SwiftData

enum SamplePages {
    private static let didLaunchKey = "vellum.didLaunch"

    static func seedIfNeeded(in container: ModelContainer) {
        let context = container.mainContext
        var descriptor = FetchDescriptor<Page>()
        descriptor.fetchLimit = 1
        let existing = (try? context.fetch(descriptor)) ?? []
        let didLaunch = UserDefaults.standard.bool(forKey: didLaunchKey)

        if SeedPolicy.shouldSeed(storeIsEmpty: existing.isEmpty, didLaunch: didLaunch) {
            for page in makeSamples(now: .now) {
                context.insert(page)
            }
            try? context.save()
        }

        UserDefaults.standard.set(true, forKey: didLaunchKey)
    }

    static func makeSamples(now: Date) -> [Page] {
        [
            Page(
                pageID: UUID(uuidString: "A11CE001-0000-4000-8000-000000000001")!,
                title: SampleDeskCopy.bookTitle,
                body: SampleDeskCopy.bookBody,
                createdAt: stamp(hoursAgo: 2, now: now),
                updatedAt: stamp(hoursAgo: 2, now: now),
                fontId: Typeface.book.rawValue,
                paperId: Paper.cream.rawValue,
                inkId: Ink.charcoal.rawValue,
                sizeId: TypeSize.m.rawValue
            ),
            Page(
                pageID: UUID(uuidString: "A11CE001-0000-4000-8000-000000000002")!,
                title: SampleDeskCopy.handTitle,
                body: SampleDeskCopy.handBody,
                createdAt: stamp(hoursAgo: 26, now: now),
                updatedAt: stamp(hoursAgo: 26, now: now),
                fontId: Typeface.hand.rawValue,
                paperId: Paper.sage.rawValue,
                inkId: Ink.forest.rawValue,
                sizeId: TypeSize.m.rawValue
            ),
            Page(
                pageID: UUID(uuidString: "A11CE001-0000-4000-8000-000000000003")!,
                title: SampleDeskCopy.typeTitle,
                body: SampleDeskCopy.typeBody,
                createdAt: stamp(hoursAgo: 90, now: now),
                updatedAt: stamp(hoursAgo: 90, now: now),
                fontId: Typeface.typewriter.rawValue,
                paperId: Paper.ruled.rawValue,
                inkId: Ink.navy.rawValue,
                sizeId: TypeSize.s.rawValue
            ),
        ]
    }

    /// Floor to the hour, then subtract, matching `sampleStamp` in `src/lib/store.ts`.
    private static func stamp(hoursAgo: Double, now: Date) -> Date {
        let hour: TimeInterval = 60 * 60
        let floored = floor(now.timeIntervalSince1970 / hour) * hour
        return Date(timeIntervalSince1970: floored - hoursAgo * hour)
    }
}
