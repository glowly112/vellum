import SwiftUI

extension Paper {
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
}

extension Ink {
    var color: Color {
        switch self {
        case .charcoal: VellumPalette.charcoal
        case .sepia: VellumPalette.sepia
        case .navy: VellumPalette.navy
        case .forest: VellumPalette.forest
        case .cream: VellumPalette.creamInk
        }
    }
}

enum HitTarget {
    static let minimum: CGFloat = 44
}
