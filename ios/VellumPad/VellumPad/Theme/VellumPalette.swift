import SwiftUI

/// Colour tokens from `src/styles.css`. Paper stays Vellum; chrome uses system tint.
enum VellumPalette {
    static let desk = Color(red: 0xE6 / 255, green: 0xD7 / 255, blue: 0xC0 / 255)
    static let paper = Color(red: 0xF3 / 255, green: 0xEB / 255, blue: 0xDD / 255)
    static let ivory = Color(red: 0xF7 / 255, green: 0xF1 / 255, blue: 0xE6 / 255)
    static let ruled = Color(red: 0xF4 / 255, green: 0xEC / 255, blue: 0xDC / 255)
    static let kraft = Color(red: 0xC4 / 255, green: 0xA5 / 255, blue: 0x74 / 255)
    static let sage = Color(red: 0xD5 / 255, green: 0xDF / 255, blue: 0xD0 / 255)
    static let fog = Color(red: 0xE5 / 255, green: 0xE2 / 255, blue: 0xDA / 255)
    static let night = Color(red: 0x1C / 255, green: 0x19 / 255, blue: 0x15 / 255)

    static let ink = Color(red: 0x2C / 255, green: 0x24 / 255, blue: 0x19 / 255)
    static let inkSoft = Color(red: 0x6B / 255, green: 0x5D / 255, blue: 0x4D / 255)
    static let inkFaint = Color(red: 0xA3 / 255, green: 0x94 / 255, blue: 0x82 / 255)
    static let charcoal = ink
    static let sepia = Color(red: 0x5C / 255, green: 0x3D / 255, blue: 0x2E / 255)
    static let navy = Color(red: 0x24 / 255, green: 0x30 / 255, blue: 0x44 / 255)
    static let forest = Color(red: 0x2A / 255, green: 0x3B / 255, blue: 0x2E / 255)
    static let creamInk = paper

    static let rule = Color(red: 0x9A / 255, green: 0xA8 / 255, blue: 0xB8 / 255)
    static let margin = Color(red: 0xC4 / 255, green: 0x5C / 255, blue: 0x5C / 255)
    static let danger = Color(red: 0x8F / 255, green: 0x3A / 255, blue: 0x32 / 255)
}
