import SwiftUI

/// Catalogue faces — the same OFL families as `src/routes/__root.tsx`.
/// Registered from `Fonts/*.ttf` via `UIAppFonts` and `TypefaceRegistry`.
enum VellumFonts {
    static func ui(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .default, weight: weight)
    }

    static func page(_ typeface: Typeface, size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        .custom(typeface.familyName, size: size, relativeTo: textStyle)
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
