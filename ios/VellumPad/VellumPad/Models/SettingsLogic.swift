import Foundation

/// Paper Settings. Not accounts, not a theme picker, not a Notes dump.
enum SettingsLook {
    static let kind = "paper-sheet"
    static let title = "Settings"
    static let gearKind = "system"
    static let gearSystemImage = "gearshape"
    static let gearPlacement = "topBarTrailing"
    static let sections = ["Connections", "Desk", "About"]
    static let connectionsTitle = "Connections"
    static let deskTitle = "Desk"
    static let aboutTitle = "About"
    static let lockRow = "Lock the desk"
    static let awakeRow = "Keep screen awake"
    static let hapticsRow = "Haptics"
    static let welcomeRow = "Welcome"
    static let aboutCopy = "Pages stay on this iPhone."
    static let marketingVersion = "1.0.0"
    static let buildNumber = "30"
    static let versionLabel = "1.0.0 (30)"
    static let lockDefault = false
    static let awakeDefault = false
    static let hapticsDefault = true
    static let welcomeDefault = false
    static let hasAccounts = false
    static let hasICloud = false
    static let hasFolders = false
    static let hasTags = false
    static let hasNotifications = false
    static let hasConfirmToDelete = false
    static let hasThemePicker = true
    static let hasMarkdown = false
    static let hasProfile = false
    /// Default tile is System. Light / Dark persist an override.
    static let followsSystemAppearance = true
    static let appearanceKey = AppearanceLook.key
    static let chromeFollowsColorScheme = true
}

/// Settings / Connections chrome. Night desk in Dark. Not catalog ivory/ink.
enum SettingsChromeLook {
    static let followsColorScheme = true
    static let usesCatalogIvory = false
    static let usesCatalogInk = false
    static let remapsCatalogPaper = false
    /// Form/sheet UIColor traits stay light. Resolve from SwiftUI ColorScheme.
    static let usesUIColorTraitCallback = false
    static let resolver = "swiftui-colorScheme"
    static let darkFill = "night"
    static let darkFillHex = "1C1915"
    static let darkRowHex = "27231E"
    static let darkType = "onDesk"
    static let darkTypeHex = "F3EBDD"
    static let lightFill = "cream"
    static let lightRowHex = "F7F1E6"
    static let lightType = "onDesk"

    static func fillKind(scheme: String) -> String {
        scheme == "dark" ? darkFill : lightFill
    }

    static func typeKind(scheme: String) -> String { "onDesk" }

    static func isNight(scheme: String) -> Bool {
        fillKind(scheme: scheme) == darkFill && typeKind(scheme: scheme) == darkType
    }

    static func isDay(scheme: String) -> Bool {
        fillKind(scheme: scheme) == lightFill && typeKind(scheme: scheme) == lightType
    }

    /// Dark / Light override wins even if the sheet’s UIKit traits stayed light.
    static func resolvedScheme(appearanceRaw: String, system: String) -> String {
        switch appearanceRaw {
        case AppearanceLook.lightRaw: return "light"
        case AppearanceLook.darkRaw: return "dark"
        default: return system
        }
    }
}

enum DeskSettings {
    static let lockKey = "vellum.settings.lockDesk"
    static let awakeKey = "vellum.settings.keepAwake"
    static let hapticsKey = "vellum.settings.haptics"
    static let welcomeKey = "vellum.settings.replayWelcome"

    static func lockDesk(in defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: lockKey)
    }

    static func keepAwake(in defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: awakeKey)
    }

    static func haptics(in defaults: UserDefaults = .standard) -> Bool {
        if defaults.object(forKey: hapticsKey) == nil { return SettingsLook.hapticsDefault }
        return defaults.bool(forKey: hapticsKey)
    }

    static func replayWelcome(in defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: welcomeKey)
    }

    static func setLockDesk(_ on: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: lockKey)
    }

    static func setKeepAwake(_ on: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: awakeKey)
    }

    static func setHaptics(_ on: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: hapticsKey)
    }

    static func setReplayWelcome(_ on: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: welcomeKey)
    }
}

enum DeskHaptics {
    static let onByDefault = SettingsLook.hapticsDefault
    static let respectsSystem = true

    static func shouldPlay(enabled: Bool) -> Bool { enabled }
}

enum WelcomeCopy {
    static let kicker = "Velin"
    static let pages: [(title: String, line: String)] = [
        ("A desk.", "Pages you keep."),
        ("Write on paper.", "Type and ink live on the page."),
        ("Import.", "They keep their date."),
    ]
    static let skip = "Skip"
    static let turn = "Turn page"
    static let done = "Done"
}

enum WelcomePreview {
    static let teachesProduct = true
    static let blankSheets = false
    static let usesSampleCopy = true
    static let libraryTitles = [
        SampleDeskCopy.typeTitle,
        SampleDeskCopy.bookTitle,
        SampleDeskCopy.handTitle,
    ]
    static let libraryBodies = [
        SampleDeskCopy.typeBody,
        SampleDeskCopy.bookBody,
        SampleDeskCopy.handBody,
    ]
    static let editorTitle = SampleDeskCopy.bookTitle
    static let editorBody = SampleDeskCopy.bookBody + "\n\n" + SampleDeskCopy.handBody
    static let importSources = ImportLook.sources
    static let importKeepsDate = ImportCopy.keepsDate
    static let staysLocal = SettingsLook.aboutCopy
}

enum WelcomeLook {
    static let kind = "brand-root"
    static let surface = "paper-on-desk"
    static let motionKind = "page-turn"
    static let reduceMotionIsInstant = true
    static let skipOnEveryPage = true
    static let pageCount = 3
    static let defaultsKey = "vellum.welcome.seen"
    static let isRoot = true
    static let coversLibrary = true
    static let libraryBehind = false
    static let hasStamp = true
    static let stampLetter = "V"
    static let blankSheets = false
    static let teachesProduct = true
    /// WelcomeMiniCard page text. Must not be `body` — that is View.body.
    static let miniCardTextProperty = "snippet"
}

enum AppearanceLook {
    static let key = "vellum.settings.appearance"
    static let systemRaw = "system"
    static let lightRaw = "light"
    static let darkRaw = "dark"
    static let defaultRaw = "system"
    static let tiles = ["System", "Light", "Dark"]
    static let persists = true

    static func raw(in defaults: UserDefaults = .standard) -> String {
        defaults.string(forKey: key) ?? defaultRaw
    }

    static func setRaw(_ value: String, in defaults: UserDefaults = .standard) {
        defaults.set(value, forKey: key)
    }

    /// nil follows the device. `"light"` / `"dark"` force the window.
    static func preferredColorScheme(in defaults: UserDefaults = .standard) -> String? {
        switch raw(in: defaults) {
        case lightRaw: return "light"
        case darkRaw: return "dark"
        default: return nil
        }
    }

    static func lightForcesLight(in defaults: UserDefaults = .standard) -> Bool {
        raw(in: defaults) == lightRaw && preferredColorScheme(in: defaults) == "light"
    }

    static func darkForcesNightDesk(in defaults: UserDefaults = .standard) -> Bool {
        raw(in: defaults) == darkRaw
            && preferredColorScheme(in: defaults) == "dark"
            && DeskLook.darkDesk == "night"
    }
}

enum WelcomeGate {
    static let defaultsKey = WelcomeLook.defaultsKey

    static func shouldShow(in defaults: UserDefaults = .standard) -> Bool {
        !defaults.bool(forKey: defaultsKey)
    }

    /// First-open, or the Desk Welcome toggle.
    static func shouldPresent(in defaults: UserDefaults = .standard) -> Bool {
        shouldShow(in: defaults) || DeskSettings.replayWelcome(in: defaults)
    }

    static func finish(in defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: defaultsKey)
        defaults.set(false, forKey: DeskSettings.welcomeKey)
    }

    static func skip(in defaults: UserDefaults = .standard) {
        finish(in: defaults)
    }
}
