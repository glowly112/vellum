import Foundation
import SwiftData

@Model
final class Page: RecencyPage {
    @Attribute(.unique) var pageID: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date
    var fontId: String
    var paperId: String
    var inkId: String
    var sizeId: String
    /// Optional so a build-7 `vellum-pages` store (no column) can open.
    /// Required `Bool` is what `fatalError`'d ModelContainer on 1.0.0 (8).
    var isPinned: Bool?

    init(
        pageID: UUID = UUID(),
        title: String = "",
        body: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        fontId: String = Typeface.book.rawValue,
        paperId: String = Paper.cream.rawValue,
        inkId: String = Ink.charcoal.rawValue,
        sizeId: String = TypeSize.m.rawValue,
        isPinned: Bool = false
    ) {
        self.pageID = pageID
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.fontId = fontId
        self.paperId = paperId
        self.inkId = inkId
        self.sizeId = sizeId
        self.isPinned = isPinned
    }

    /// Missing column (build 7) and nil both read as unpinned.
    var pinOn: Bool {
        get { isPinned ?? false }
        set { isPinned = newValue }
    }

    var typeface: Typeface { Catalog.typeface(fontId) }
    var paper: Paper { Catalog.paper(paperId) }
    var ink: Ink { Ink.resolve(Catalog.ink(inkId), on: paper) }
    var typeSize: TypeSize { Catalog.size(sizeId) }

    var displayTitle: String { PageCopy.displayTitle(title: title, body: body) }
    var preview: String { PageCopy.preview(body) }
    var words: Int { PageCopy.wordCount(title, body) }

    func revise(title: String? = nil, body: String? = nil) {
        if let title { self.title = title }
        if let body { self.body = body }
        updatedAt = .now
    }

    func snapshot() -> EditorSnapshot {
        EditorSnapshot(pageID: pageID, title: title, body: body, updatedAt: updatedAt)
    }

    var trashSnapshot: DeletedPage {
        DeletedPage(
            pageID: pageID,
            title: title,
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt,
            fontId: fontId,
            paperId: paperId,
            inkId: inkId,
            sizeId: sizeId,
            isPinned: isPinned
        )
    }

    static func restored(from deleted: DeletedPage) -> Page {
        Page(
            pageID: deleted.pageID,
            title: deleted.title,
            body: deleted.body,
            createdAt: deleted.createdAt,
            updatedAt: deleted.updatedAt,
            fontId: deleted.fontId,
            paperId: deleted.paperId,
            inkId: deleted.inkId,
            sizeId: deleted.sizeId,
            isPinned: deleted.isPinned ?? false
        )
    }

    func apply(style: PageStyle) {
        fontId = style.typeface.rawValue
        paperId = style.paper.rawValue
        inkId = Ink.resolve(style.ink, on: style.paper).rawValue
        sizeId = style.size.rawValue
        updatedAt = .now
        StylePreferences.remember(style)
    }
}

struct PageStyle: Equatable, Sendable {
    var typeface: Typeface
    var paper: Paper
    var ink: Ink
    var size: TypeSize

    var resolvedInk: Ink { Ink.resolve(ink, on: paper) }

    static let `default` = PageStyle(
        typeface: .book,
        paper: .cream,
        ink: .charcoal,
        size: .m
    )

    init(typeface: Typeface, paper: Paper, ink: Ink, size: TypeSize) {
        self.typeface = typeface
        self.paper = paper
        self.ink = Ink.resolve(ink, on: paper)
        self.size = size
    }

    init(page: Page) {
        self.init(
            typeface: page.typeface,
            paper: page.paper,
            ink: page.ink,
            size: page.typeSize
        )
    }
}

struct EditorSnapshot: Equatable {
    let pageID: UUID
    let title: String
    let body: String
    let updatedAt: Date

    func matchesLive(_ page: Page) -> Bool {
        page.pageID == pageID
            && page.title == title
            && page.body == body
            && page.updatedAt == updatedAt
    }
}

enum StylePreferences {
    private static let typefaceKey = "vellum.prefs.fontId"
    private static let paperKey = "vellum.prefs.paperId"
    private static let inkKey = "vellum.prefs.inkId"
    private static let sizeKey = "vellum.prefs.sizeId"

    static var last: PageStyle {
        let paper = Catalog.paper(UserDefaults.standard.string(forKey: paperKey) ?? Paper.cream.rawValue)
        let ink = Catalog.ink(UserDefaults.standard.string(forKey: inkKey) ?? paper.defaultInk.rawValue)
        return PageStyle(
            typeface: Catalog.typeface(UserDefaults.standard.string(forKey: typefaceKey) ?? Typeface.book.rawValue),
            paper: paper,
            ink: ink,
            size: Catalog.size(UserDefaults.standard.string(forKey: sizeKey) ?? TypeSize.m.rawValue)
        )
    }

    static func remember(_ style: PageStyle) {
        let resolved = PageStyle(
            typeface: style.typeface,
            paper: style.paper,
            ink: style.resolvedInk,
            size: style.size
        )
        UserDefaults.standard.set(resolved.typeface.rawValue, forKey: typefaceKey)
        UserDefaults.standard.set(resolved.paper.rawValue, forKey: paperKey)
        UserDefaults.standard.set(resolved.ink.rawValue, forKey: inkKey)
        UserDefaults.standard.set(resolved.size.rawValue, forKey: sizeKey)
    }
}
