import SwiftUI
import UIKit

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

    /// Library greeting — Fraunces italic at the **system large-title** size.
    /// Not a guessed 34. `relativeTo: .largeTitle` tracks Dynamic Type.
    static func display(size: CGFloat? = nil) -> Font {
        let points = size ?? UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        return .custom(Typeface.editorial.familyName, size: points, relativeTo: .largeTitle)
            .italic()
    }

    /// Date · pages under the greeting. Fraunces roman at subheadline.
    /// Same desk family, quieter role — not italic, not largeTitle, not SF.
    static func deskMeta() -> Font {
        let points = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
        return .custom(Typeface.editorial.familyName, size: points, relativeTo: .subheadline)
    }

    /// How far italic Fraunces overshoots the system large-title ascender.
    static func greetingTopAir() -> CGFloat {
        let system = UIFont.preferredFont(forTextStyle: .largeTitle)
        guard let face = UIFont(name: Typeface.editorial.familyName, size: system.pointSize) else {
            return 0
        }
        var descriptor = face.fontDescriptor
        if let italic = descriptor.withSymbolicTraits([descriptor.symbolicTraits, .traitItalic]) {
            descriptor = italic
        }
        let italicFace = UIFont(descriptor: descriptor, size: system.pointSize)
        return CGFloat(
            LibraryGreeting.italicOvershoot(
                systemAscender: Double(system.ascender),
                faceAscender: Double(italicFace.ascender)
            )
        )
    }
}
