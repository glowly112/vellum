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
    static let aboutCopy = "Pages stay on this iPhone."
    static let marketingVersion = "1.0.0"
    static let buildNumber = "27"
    static let versionLabel = "1.0.0 (27)"
    static let lockDefault = false
    static let awakeDefault = false
    static let hapticsDefault = true
    static let hasAccounts = false
    static let hasICloud = false
    static let hasFolders = false
    static let hasTags = false
    static let hasNotifications = false
    static let hasConfirmToDelete = false
    static let hasThemePicker = false
    static let hasMarkdown = false
    static let hasProfile = false
    static let followsSystemAppearance = true
}

enum DeskSettings {
    static let lockKey = "vellum.settings.lockDesk"
    static let awakeKey = "vellum.settings.keepAwake"
    static let hapticsKey = "vellum.settings.haptics"

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

    static func setLockDesk(_ on: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: lockKey)
    }

    static func setKeepAwake(_ on: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: awakeKey)
    }

    static func setHaptics(_ on: Bool, in defaults: UserDefaults = .standard) {
        defaults.set(on, forKey: hapticsKey)
    }
}

enum DeskHaptics {
    static let onByDefault = SettingsLook.hapticsDefault
    static let respectsSystem = true

    static func shouldPlay(enabled: Bool) -> Bool { enabled }
}

enum WelcomeCopy {
    static let pages: [(title: String, line: String)] = [
        ("A desk.", "Pages you keep."),
        ("Write on paper.", ""),
        ("Bring thoughts in.", "They keep their date."),
    ]
    static let skip = "Skip"
    static let turn = "Turn page"
    static let done = "Done"
}

enum WelcomeLook {
    static let kind = "paper-on-desk"
    static let motionKind = "page-turn"
    static let reduceMotionIsInstant = true
    static let skipOnEveryPage = true
    static let pageCount = 3
    static let defaultsKey = "vellum.welcome.seen"
}

enum WelcomeGate {
    static let defaultsKey = WelcomeLook.defaultsKey

    static func shouldShow(in defaults: UserDefaults = .standard) -> Bool {
        !defaults.bool(forKey: defaultsKey)
    }

    static func finish(in defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: defaultsKey)
    }

    static func skip(in defaults: UserDefaults = .standard) {
        finish(in: defaults)
    }
}
