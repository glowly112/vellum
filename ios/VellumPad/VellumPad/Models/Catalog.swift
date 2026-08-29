import SwiftUI

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

    var fill: Color {
        switch self {
        case .cream: VellumPalette.paper
        case .ivory: VellumPalette.ivory
        case .ruled: VellumPalette.ruled
        case .dotted: VellumPalette.fog
        case .kraft: VellumPalette.kraft
        case .sage: VellumPalette.sage
        case .fog: VellumPalette.fog
        case .night: VellumPalette.night
        }
    }

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

    var color: Color {
        switch self {
        case .charcoal: VellumPalette.charcoal
        case .sepia: VellumPalette.sepia
        case .navy: VellumPalette.navy
        case .forest: VellumPalette.forest
        case .cream: VellumPalette.creamInk
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
    var titlePoints: CGFloat {
        switch self {
        case .s: 23
        case .m: 29
        case .l: 34
        }
    }

    var bodyPoints: CGFloat {
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

    var ruleHeight: CGFloat {
        bodyPoints * (self == .s ? 1.85 : self == .m ? 2.05 : 2.25)
    }
}

enum Catalog {
    static func typeface(_ raw: String) -> Typeface { Typeface(rawValue: raw) ?? .book }
    static func paper(_ raw: String) -> Paper { Paper(rawValue: raw) ?? .cream }
    static func ink(_ raw: String) -> Ink { Ink(rawValue: raw) ?? .charcoal }
    static func size(_ raw: String) -> TypeSize { TypeSize(rawValue: raw) ?? .m }
}
