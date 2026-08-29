import SwiftUI

/// Web catalogue uses Literata / Fraunces / Caveat / Special Elite / Source Sans 3 / IBM Plex Mono.
/// Those webfonts are OFL, but this target uses the closest system faces shipped on iOS
/// (Georgia / Palatino / Noteworthy / American Typewriter / SF / SF Mono) so we do not
/// redistribute font binaries.
enum VellumFonts {
    static func ui(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .default, weight: weight)
    }

    static func page(_ typeface: Typeface, size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        switch typeface {
        case .book:
            return .custom("Georgia", size: size, relativeTo: textStyle)
        case .editorial:
            return .custom("Palatino-Roman", size: size, relativeTo: textStyle)
        case .hand:
            return .custom("Noteworthy-Light", size: size, relativeTo: textStyle)
        case .typewriter:
            return .custom("AmericanTypewriter", size: size, relativeTo: textStyle)
        case .sans:
            return .system(size: size, weight: .regular, design: .default)
        case .mono:
            return .system(size: size, weight: .regular, design: .monospaced)
        }
    }

    static func title(_ typeface: Typeface, size: TypeSize) -> Font {
        page(typeface, size: CGFloat(size.titlePoints), relativeTo: .title)
    }

    static func body(_ typeface: Typeface, size: TypeSize) -> Font {
        page(typeface, size: CGFloat(size.bodyPoints), relativeTo: .body)
    }

    static func sample(_ typeface: Typeface) -> Font {
        page(typeface, size: 20, relativeTo: .title3)
    }
}
