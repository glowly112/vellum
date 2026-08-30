import Foundation

/// Mirrors `src/lib/catalog.ts`. Keep ids and names in lockstep with the web desk.
enum Typeface: String, CaseIterable, Identifiable, Codable, Sendable {
    case book
    case editorial
    case hand
    case typewriter
    case sans
    case mono

    var id: String { rawValue }

    var name: String {
        switch self {
        case .book: "Book"
        case .editorial: "Editorial"
        case .hand: "Hand"
        case .typewriter: "Typewriter"
        case .sans: "Sans"
        case .mono: "Mono"
        }
    }

    var sample: String {
        switch self {
        case .book: "The page waits quietly."
        case .editorial: "A wider, slower sentence."
        case .hand: "as if written in the margin"
        case .typewriter: "NOTES FROM THE DESK"
        case .sans: "Clear, unadorned thought."
        case .mono: "draft.txt — keep going"
        }
    }

    /// PostScript-family names of the bundled OFL faces (same as the web desk).
    var familyName: String {
        switch self {
        case .book: "Literata"
        case .editorial: "Fraunces"
        case .hand: "Caveat"
        case .typewriter: "Special Elite"
        case .sans: "Source Sans 3"
        case .mono: "IBM Plex Mono"
        }
    }
}

enum Paper: String, CaseIterable, Identifiable, Codable, Sendable {
    case cream
    case ivory
    case ruled
    case dotted
    case kraft
    case sage
    case fog
    case night

    var id: String { rawValue }

    var name: String {
        switch self {
        case .cream: "Cream"
        case .ivory: "Ivory"
        case .ruled: "Ruled"
        case .dotted: "Dotted"
        case .kraft: "Kraft"
        case .sage: "Sage"
        case .fog: "Fog"
        case .night: "Night"
        }
    }

    enum Ruling: Sendable {
        case none
        case lines
        case dots
    }

    var ruling: Ruling {
        switch self {
        case .ruled: .lines
        case .dotted: .dots
        default: .none
        }
    }

    var isDark: Bool { self == .night }

    var defaultInk: Ink {
        switch self {
        case .ruled, .fog: .navy
        case .sage: .forest
        case .night: .cream
        default: .charcoal
        }
    }
}

enum Ink: String, CaseIterable, Identifiable, Codable, Sendable {
    case charcoal
    case sepia
    case navy
    case forest
    case cream

    var id: String { rawValue }

    var name: String {
        switch self {
        case .charcoal: "Charcoal"
        case .sepia: "Sepia"
        case .navy: "Navy"
        case .forest: "Forest"
        case .cream: "Cream"
        }
    }

    static func allowed(on paper: Paper) -> [Ink] {
        if paper.isDark { return [.cream, .sepia] }
        if paper == .kraft { return [.charcoal, .sepia, .navy] }
        return [.charcoal, .sepia, .navy, .forest]
    }

    static func resolve(_ ink: Ink, on paper: Paper) -> Ink {
        let allowed = allowed(on: paper)
        return allowed.contains(ink) ? ink : paper.defaultInk
    }
}

enum TypeSize: String, CaseIterable, Identifiable, Codable, Sendable {
    case s
    case m
    case l

    var id: String { rawValue }

    var name: String {
        switch self {
        case .s: "S"
        case .m: "M"
        case .l: "L"
        }
    }

    /// Matches `--title-size` / `--body-size` in `src/styles.css`.
    var titlePoints: Double {
        switch self {
        case .s: 23
        case .m: 29
        case .l: 34
        }
    }

    var bodyPoints: Double {
        switch self {
        case .s: 17
        case .m: 19
        case .l: 21
        }
    }

    var bodyLeading: CGFloat {
        switch self {
        case .s: 1.7
        case .m: 1.75
        case .l: 1.8
        }
    }

    /// Editor line box matches `PaperRuling.pitch`, not a size-specific leading.
    var ruleHeight: CGFloat { CGFloat(PaperRuling.pitch) }
}

/// Shared grid for `PaperBackdrop` rules/dots and title/body leading.
/// Editor pitch is 32. Compact (library swatches) stays 22 / 16 so library cards do not change.
enum PaperRuling {
    static let pitch: Double = 32
    static let compactPitch: Double = 22
    static let compactDotPitch: Double = 16
    static let titlePitches: Double = 2
    /// First rule Y in the writing column so title + body sit on the grid.
    static let firstRuleOffset: Double = 64

    static func step(ruling: Paper.Ruling, compact: Bool) -> Double {
        switch ruling {
        case .lines: compact ? compactPitch : pitch
        case .dots: compact ? compactDotPitch : pitch
        case .none: compact ? compactPitch : pitch
        }
    }

    /// `TextEditor` / `TextField` `lineSpacing` is extra gap, not the full line box.
    static func lineSpacing(fontPoints: Double, pitches: Double = 1) -> Double {
        max(0, pitch * pitches - fontPoints)
    }

    static func bodyLineHeight(bodyPoints: Double) -> Double {
        bodyPoints + lineSpacing(fontPoints: bodyPoints)
    }

    static func titleLineHeight(titlePoints: Double) -> Double {
        titlePoints + lineSpacing(fontPoints: titlePoints, pitches: titlePitches)
    }

    static func sitsOnRule(_ lineHeight: Double) -> Bool {
        let remainder = lineHeight.truncatingRemainder(dividingBy: pitch)
        return remainder < 0.05 || abs(remainder - pitch) < 0.05
    }
}

enum Catalog {
    static func typeface(_ raw: String) -> Typeface { Typeface(rawValue: raw) ?? .book }
    static func paper(_ raw: String) -> Paper { Paper(rawValue: raw) ?? .cream }
    static func ink(_ raw: String) -> Ink { Ink(rawValue: raw) ?? .charcoal }
    static func size(_ raw: String) -> TypeSize { TypeSize(rawValue: raw) ?? .m }
}
