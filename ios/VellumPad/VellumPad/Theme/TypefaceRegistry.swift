import CoreText
import Foundation

enum TypefaceRegistry {
    static let files: [(name: String, ext: String)] = [
        ("Literata-Regular", "ttf"),
        ("Fraunces-Regular", "ttf"),
        ("Caveat-Regular", "ttf"),
        ("SpecialElite-Regular", "ttf"),
        ("SourceSans3-Regular", "ttf"),
        ("IBMPlexMono-Regular", "ttf"),
    ]

    static func register() {
        for file in files {
            let url =
                Bundle.main.url(forResource: file.name, withExtension: file.ext, subdirectory: "Fonts")
                ?? Bundle.main.url(forResource: file.name, withExtension: file.ext)
            guard let url else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
