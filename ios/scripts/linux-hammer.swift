import Foundation

var failures = 0

func expect(_ condition: Bool, _ name: String) {
    if condition {
        print("PASS  \(name)")
    } else {
        failures += 1
        print("FAIL  \(name)")
    }
}

let now = Date(timeIntervalSince1970: 1_777_237_200)

expect(PageCopy.displayTitle(title: "", body: "First line\nSecond") == "First line", "empty title uses first body line")
expect(PageCopy.displayTitle(title: "   ", body: "") == "Untitled page", "empty title and body is Untitled page")
expect(PageCopy.displayTitle(title: "Kept", body: "ignored") == "Kept", "explicit title wins")

expect(
    ComposePolicy.reuseBlankPage(createdAt: now, title: "", body: "", now: now.addingTimeInterval(0.2)),
    "double tap compose reuses blank"
)
expect(
    !ComposePolicy.reuseBlankPage(createdAt: now, title: "", body: "", now: now.addingTimeInterval(2)),
    "compose cooldown expires"
)
expect(
    !ComposePolicy.reuseBlankPage(createdAt: now, title: "Named", body: "", now: now.addingTimeInterval(0.2)),
    "named page is a new sheet"
)

expect(SeedPolicy.shouldSeed(storeIsEmpty: true, didLaunch: false), "first-run seeds")
expect(!SeedPolicy.shouldSeed(storeIsEmpty: true, didLaunch: true), "second launch does not reseed empty desk")
expect(!SeedPolicy.shouldSeed(storeIsEmpty: false, didLaunch: false), "existing pages are not replaced")

let pages = [PageRecord(title: "River", body: "water", updatedAt: now)]
expect(LibraryGrouping.group(pages: pages, query: "zebra", now: now).isEmpty, "empty search")
expect(!LibraryGrouping.group(pages: pages, query: "", now: now).isEmpty, "blank query keeps pages")

let recency = [
    PageRecord(title: "Now", body: "desk", updatedAt: now),
    PageRecord(title: "Old", body: "last month", updatedAt: now.addingTimeInterval(-20 * 24 * 60 * 60)),
]
let keys = LibraryGrouping.group(pages: recency, query: "", now: now).map(\.section)
expect(keys == [.today, .earlier], "recency buckets")

expect(StyleSheetLayout.sections.last == "Size", "style sheet last row is Size")
expect(KeyboardAvoidance.guessedBottomPoints == nil, "no guessed keyboard pad")
expect(Ink.allowed(on: .night) == [.cream, .sepia], "night paper inks")
expect(Typeface.book.familyName == "Literata", "Book is Literata")
expect(Typeface.editorial.familyName == "Fraunces", "Editorial is Fraunces")
expect(Typeface.hand.familyName == "Caveat", "Hand is Caveat")
expect(Typeface.typewriter.familyName == "Special Elite", "Typewriter is Special Elite")
expect(Typeface.sans.familyName == "Source Sans 3", "Sans is Source Sans 3")
expect(Typeface.mono.familyName == "IBM Plex Mono", "Mono is IBM Plex Mono")
expect(DeleteDecision.shouldDelete(confirmed: false) == false, "delete cancel")
expect(DeleteDecision.shouldDelete(confirmed: true) == true, "delete confirm")

expect(PagePlainText.fileName(title: "", body: "") == "Untitled page.txt", "share untitled filename")
expect(PagePlainText.fileName(title: "UI/UX", body: "") == "UI-UX.txt", "share sanitizes slash")
expect(PagePlainText.contents(title: "Title", body: "Body") == "Title\n\nBody", "share txt body")

if failures == 0 {
    print("linux-hammer: \(0) failures")
    exit(0)
} else {
    print("linux-hammer: \(failures) failures")
    exit(1)
}
