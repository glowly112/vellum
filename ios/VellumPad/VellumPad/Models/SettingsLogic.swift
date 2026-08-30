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
    static let buildNumber = "32"
    static let versionLabel = "1.0.0 (32)"
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
    static let kicker = ""
    static let pages: [(title: String, line: String)] = [
        ("Pages you keep.", ""),
        ("Write on paper.", "Type and ink live on the page."),
        ("Import.", "They keep their date."),
    ]
    static let skip = "Skip"
    static let turn = "Turn page"
    static let done = "Done"

    static var userFacing: [String] {
        [kicker, skip, turn, done] + pages.flatMap { [$0.title, $0.line] }
    }

    static func containsAppNameOrDesk(_ text: String) -> Bool {
        let lower = text.lowercased()
        return lower.contains("velin")
            || lower.contains("vellum")
            || lower.contains("desk")
    }
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
    static let surface = "product-preview"
    static let motionKind = "page-turn"
    static let openingBeat = "sheet-then-letterpress"
    static let reduceMotionIsInstant = true
    static let skipOnEveryPage = true
    static let pageCount = 3
    static let defaultsKey = "vellum.welcome.seen"
    static let isRoot = true
    static let coversLibrary = true
    static let libraryBehind = false
    /// Paper stamp (cream, rust margin, serif V). Not the word Velin.
    static let hasStamp = true
    static let showsAppName = false
    static let stampLetter = "V"
    static let stampWritesName = false
    static let bounceResponse = DeskMotion.response
    static let bounceDamping = DeskMotion.damping
    /// Cream sheet lands first, then the 80pt stamp presses. Not a giant V.
    static let sheetArrives = true
    static let sheetOwnsScreen = true
    static let sheetSettle = 0.55
    static let letterpress = true
    static let letterpressHaptic = true
    static let scalesStampUp = false
    static let stampSide = 80.0
    static let stampFillsMiddle = false
    /// Letterpress: proud then press. Not a grow-up from 0.78.
    static let bounceStartScale = 1.16
    static let bounceStartOffset = -14.0
    static let bounceSettle = 0.55
    static let openingSettle = 1.15
    static let exitKind = "page-turn"
    static let skipExitKind = "spring-fade"
    static let exitIsCut = false
    static let autoAdvanceAfterStamp = true
    static let cardsArrive = true
    static let staggerStep = 0.08
    static let typesWriting = true
    static let typeInterval = 0.045
    static let typeShowsCursor = false
    static let blankSheets = false
    static let teachesProduct = true
    /// WelcomeMiniCard page text. Must not be `body` — that is View.body.
    static let miniCardTextProperty = "snippet"
    /// Stamp bounce advances to Pages you keep. It must not call finish().
    static let stampCallsFinish = false
}

/// Prefix reveal. No cursor. Reduce Motion shows the full string.
enum WelcomeTypewriter {
    static let interval = WelcomeLook.typeInterval
    static let showsCursor = WelcomeLook.typeShowsCursor
    static let reduceMotionShowsFull = true

    static func visible(full: String, revealed: Int) -> String {
        if revealed <= 0 { return "" }
        if revealed >= full.count { return full }
        let end = full.index(full.startIndex, offsetBy: revealed)
        return String(full[..<end])
    }
}

/// How welcome leaves. Done turns into the library. Skip is quicker. Not a cut.
enum WelcomeExit: String, Equatable, Sendable {
    case skip
    case done
}

/// Turn page / Done capsule. Never cream-on-cream. Skip stays onDesk.
enum WelcomeChromeLook {
    static let turnFillLight = "ink"
    static let turnFillLightHex = "2C2419"
    static let turnLabelLight = "paper"
    static let turnLabelLightHex = "F3EBDD"
    static let turnFillDark = "rust"
    static let turnFillDarkHex = "C45C4A"
    static let turnLabelDark = "paper"
    static let turnLabelDarkHex = "F3EBDD"
    static let usesOnDeskFill = false
    static let creamOnCream = false
    static let skipUsesOnDesk = true

    static func turnFillKind(scheme: String) -> String {
        scheme == "dark" ? turnFillDark : turnFillLight
    }

    static func turnLabelKind(scheme: String) -> String { "paper" }

    static func contrasts(scheme: String) -> Bool {
        let fill = turnFillKind(scheme: scheme)
        let label = turnLabelKind(scheme: scheme)
        return fill != "paper" && fill != "onDesk" && fill != "cream"
            && label == "paper"
    }
}

/// Writing on a cream catalog sheet. Never Color.primary / onDesk traits.
enum WelcomeInkLook {
    static let sheetInk = "charcoal"
    static let sheetUsesPrimary = false
    static let sheetUsesOnDesk = false
    static let sheetInkFlipsWithScheme = false
    static let headlineUsesOnDesk = true
    static let creamSheetsStayCream = true
}

enum AppearanceLook {
    static let key = "vellum.settings.appearance"
    static let systemRaw = "system"
    static let lightRaw = "light"
    static let darkRaw = "dark"
    static let defaultRaw = "system"
    static let tiles = ["System", "Light", "Dark"]
    static let persists = true
    /// One AppStorage key at the root. Tiles write that key. No local sheet @State.
    static let retintsWholeApp = true
    static let appliesPreferredColorSchemeAtRoot = true
    static let appliesPreferredColorSchemeOnSheets = true
    static let usesLocalSheetState = false
    static let catalogSheetsStayCream = true

    static func raw(in defaults: UserDefaults = .standard) -> String {
        defaults.string(forKey: key) ?? defaultRaw
    }

    static func setRaw(_ value: String, in defaults: UserDefaults = .standard) {
        defaults.set(value, forKey: key)
    }

    /// nil follows the device. `"light"` / `"dark"` force the window.
    static func preferredColorScheme(raw: String) -> String? {
        switch raw {
        case lightRaw: return "light"
        case darkRaw: return "dark"
        default: return nil
        }
    }

    static func preferredColorScheme(in defaults: UserDefaults = .standard) -> String? {
        preferredColorScheme(raw: raw(in: defaults))
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
    /// App root reads this helper, not a pair of @AppStorage copies.
    static let rootUsesShouldPresent = true
    static let usesAppStorageCopies = false
    static let stampCallsFinish = false

    /// Absent key or explicit false → first-open. Only `true` is seen.
    static func shouldShow(in defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: defaultsKey) as? Bool != true
    }

    /// First-open, replay toggle, or Debug `VELLUM_FORCE_WELCOME=1`.
    /// `VELLUM_OPEN_FIRST` hides welcome only when Mini asked for the editor.
    static func shouldPresent(
        in defaults: UserDefaults = .standard,
        environment: [String: String] = ProcessInfo.processInfo.environment,
        debugBuild: Bool = DebugForceWelcome.compileGateEnabled
    ) -> Bool {
        if DebugForceWelcome.shouldForce(environment: environment, debugBuild: debugBuild) {
            return true
        }
        if DebugOpenFirst.shouldOpenFirstPage(environment: environment, debugBuild: debugBuild) {
            return false
        }
        return shouldShow(in: defaults) || DeskSettings.replayWelcome(in: defaults)
    }

    /// Persist replay before any sheet dismiss so the root can see it.
    static func startReplay(in defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: DeskSettings.welcomeKey)
    }

    static func finish(in defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: defaultsKey)
        defaults.set(false, forKey: DeskSettings.welcomeKey)
    }

    static func skip(in defaults: UserDefaults = .standard) {
        finish(in: defaults)
    }
}
