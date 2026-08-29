import Foundation

/// Recency buckets from `src/lib/library.ts`. The only organisation.
enum LibrarySection: String, CaseIterable, Identifiable, Sendable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This week"
    case earlier = "Earlier"

    var id: String { rawValue }
    var title: String { rawValue }
}

protocol RecencyPage {
    var title: String { get }
    var body: String { get }
    var updatedAt: Date { get }
}

struct PageRecord: RecencyPage, Equatable {
    var title: String
    var body: String
    var updatedAt: Date
}

enum LibraryGrouping {
    static func matchesQuery(title: String, body: String, query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return true }
        return "\(title)\n\(body)".lowercased().contains(q)
    }

    static func section(for date: Date, now: Date = .now) -> LibrarySection {
        let cal = Calendar.current
        let startNow = cal.startOfDay(for: now)
        let startThen = cal.startOfDay(for: date)
        let days = cal.dateComponents([.day], from: startThen, to: startNow).day ?? 0
        if days <= 0 { return .today }
        if days == 1 { return .yesterday }
        if days < 7 { return .thisWeek }
        return .earlier
    }

    static func group<P: RecencyPage>(
        pages: [P],
        query: String,
        now: Date = .now
    ) -> [(section: LibrarySection, pages: [P])] {
        let filtered = pages
            .filter { matchesQuery(title: $0.title, body: $0.body, query: query) }
            .sorted { $0.updatedAt > $1.updatedAt }

        var map: [LibrarySection: [P]] = [:]
        for page in filtered {
            map[section(for: page.updatedAt, now: now), default: []].append(page)
        }
        return LibrarySection.allCases.compactMap { key in
            guard let list = map[key], !list.isEmpty else { return nil }
            return (key, list)
        }
    }
}

enum PageCopy {
    static func wordCount(_ parts: String...) -> Int {
        let text = parts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return 0 }
        return text.split { $0.isWhitespace || $0.isNewline }.count
    }

    static func displayTitle(title: String, body: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        let line = body
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
        return line ?? "Untitled page"
    }

    static func preview(_ body: String) -> String {
        body.split { $0.isWhitespace || $0.isNewline }.joined(separator: " ")
    }

    static func whenLabel(_ date: Date, now: Date = .now) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        if cal.isDateInYesterday(date) {
            return "Yesterday"
        }
        return date.formatted(.dateTime.day().month(.abbreviated))
    }

    static func longDate(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased()
    }

    static func greeting(at date: Date = .now) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }
}
