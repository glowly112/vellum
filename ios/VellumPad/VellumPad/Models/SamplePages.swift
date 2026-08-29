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
                title: "Late light on the river",
                body: "The Thames is the colour of pewter this evening. I walked home with my headphones in but nothing playing — I just wanted the city a little quieter than it is.\n\nI keep meaning to write more, and then the day is gone. So here: the light on the water, the smell of rain that never quite arrived, the page waiting.",
                createdAt: stamp(hoursAgo: 2, now: now),
                updatedAt: stamp(hoursAgo: 2, now: now),
                fontId: Typeface.book.rawValue,
                paperId: Paper.cream.rawValue,
                inkId: Ink.charcoal.rawValue,
                sizeId: TypeSize.m.rawValue
            ),
            Page(
                pageID: UUID(uuidString: "A11CE001-0000-4000-8000-000000000002")!,
                title: "things I noticed",
                body: "rain on warm pavement\na blank page is never actually blank\nthe way a good sentence feels before it is written\ncall mum\nleave the phone in the other room",
                createdAt: stamp(hoursAgo: 26, now: now),
                updatedAt: stamp(hoursAgo: 26, now: now),
                fontId: Typeface.hand.rawValue,
                paperId: Paper.sage.rawValue,
                inkId: Ink.forest.rawValue,
                sizeId: TypeSize.m.rawValue
            ),
            Page(
                pageID: UUID(uuidString: "A11CE001-0000-4000-8000-000000000003")!,
                title: "Notes",
                body: "- send the draft before Monday\n- oat milk, lemons, too many lemons\n- do not open email after nine\n- the opening line is still wrong\n- walk at lunch",
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
