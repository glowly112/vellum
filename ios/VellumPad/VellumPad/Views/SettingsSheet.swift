import LocalAuthentication
import SwiftData
import SwiftUI

private enum SettingsRoute: Hashable {
    case connections
}

/// Paper Settings. Inset grouped chrome on Velin paper — not Notes gray.
struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Binding var openConnections: Bool
    var message: String
    var isError: Bool

    @AppStorage(DeskSettings.lockKey) private var lockDesk = SettingsLook.lockDefault
    @AppStorage(DeskSettings.awakeKey) private var keepAwake = SettingsLook.awakeDefault
    @AppStorage(DeskSettings.hapticsKey) private var haptics = SettingsLook.hapticsDefault
    @AppStorage(DeskSettings.welcomeKey) private var replayWelcome = SettingsLook.welcomeDefault
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw
    @State private var path = NavigationPath()

    /// Dark / Light from AppStorage this tap. Do not trust UIColor traits in a sheet.
    private var chromeScheme: ColorScheme {
        VellumPalette.resolvedScheme(appearanceRaw: appearanceRaw, system: colorScheme)
    }

    private var chromeFill: Color { VellumPalette.chrome(for: chromeScheme) }
    private var chromeRow: Color { VellumPalette.chromeRow(for: chromeScheme) }
    private var chromeInk: Color { VellumPalette.onDesk(for: chromeScheme) }
    private var chromeInkSoft: Color { VellumPalette.onDeskSoft(for: chromeScheme) }

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section {
                    NavigationLink(SettingsLook.connectionsTitle, value: SettingsRoute.connections)
                        .listRowBackground(chromeRow)
                }

                Section(SettingsLook.deskTitle) {
                    appearanceTiles
                        .listRowBackground(chromeRow)
                    Toggle(SettingsLook.lockRow, isOn: $lockDesk)
                        .listRowBackground(chromeRow)
                    Toggle(SettingsLook.awakeRow, isOn: $keepAwake)
                        .listRowBackground(chromeRow)
                    Toggle(SettingsLook.hapticsRow, isOn: $haptics)
                        .listRowBackground(chromeRow)
                    Toggle(SettingsLook.welcomeRow, isOn: $replayWelcome)
                        .listRowBackground(chromeRow)
                }

                Section(SettingsLook.aboutTitle) {
                    Text(SettingsLook.aboutCopy)
                        .listRowBackground(chromeRow)
                    LabeledContent("Version", value: SettingsLook.versionLabel)
                        .listRowBackground(chromeRow)
                }
            }
            .font(VellumFonts.page(.book, size: 17, relativeTo: .body))
            .foregroundStyle(chromeInk)
            .scrollContentBackground(.hidden)
            .background(chromeFill.ignoresSafeArea(.container))
            .navigationTitle(SettingsLook.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(chromeFill, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(chromeScheme, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                    .accessibilityLabel("Close")
                }
            }
            .navigationDestination(for: SettingsRoute.self) { _ in
                ConnectionsPage(
                    incomingMessage: message,
                    incomingIsError: isError
                )
            }
            .onChange(of: openConnections) { _, on in
                if on, !path.isEmpty { return }
                if on { path.append(SettingsRoute.connections) }
            }
            .onChange(of: lockDesk) { _, on in
                if on {
                    Task { await confirmLock() }
                }
            }
            .onChange(of: replayWelcome) { _, on in
                if on { dismiss() }
            }
            .onAppear {
                if openConnections, path.isEmpty {
                    path.append(SettingsRoute.connections)
                }
            }
        }
        .tint(VellumPalette.rust)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(chromeFill)
        .velinAppearance(appearanceRaw)
    }

    private var appearanceTiles: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(VellumFonts.page(.book, size: 13, relativeTo: .caption))
                .foregroundStyle(chromeInkSoft)
            HStack(spacing: 10) {
                appearanceTile(AppearanceLook.systemRaw, title: "System")
                appearanceTile(AppearanceLook.lightRaw, title: "Light")
                appearanceTile(AppearanceLook.darkRaw, title: "Dark")
            }
        }
        .padding(.vertical, 4)
    }

    private func appearanceTile(_ raw: String, title: String) -> some View {
        let selected = appearanceRaw == raw
        return Button {
            DeskHapticsPlay.tick()
            appearanceRaw = raw
        } label: {
            VStack(spacing: 8) {
                AppearanceDeskPreview(mode: raw)
                    .frame(height: 74)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(
                                selected ? VellumPalette.rust : chromeInk.opacity(0.18),
                                lineWidth: selected ? 2 : 0.8
                            )
                    }
                Text(title)
                    .font(VellumFonts.page(.book, size: 13, relativeTo: .caption))
                    .foregroundStyle(selected ? VellumPalette.rust : chromeInk)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func confirmLock() async {
        let ok = await DeskLock.evaluate()
        if !ok {
            lockDesk = false
        }
    }
}

/// Mini desk mock for System / Light / Dark. Cream catalog sheets stay cream.
private struct AppearanceDeskPreview: View {
    let mode: String

    var body: some View {
        ZStack {
            deskFill
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(VellumPalette.ivory)
                    .frame(height: 16)
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(VellumPalette.paper)
                    .frame(height: 16)
            }
            .padding(8)
        }
    }

    @ViewBuilder
    private var deskFill: some View {
        switch mode {
        case AppearanceLook.darkRaw:
            VellumPalette.night
        case AppearanceLook.lightRaw:
            Color(red: 0xE6 / 255, green: 0xD7 / 255, blue: 0xC0 / 255)
        default:
            HStack(spacing: 0) {
                Color(red: 0xE6 / 255, green: 0xD7 / 255, blue: 0xC0 / 255)
                VellumPalette.night
            }
        }
    }
}

/// Named sources on paper. Logo, name, Import. File picker lives here so it presents.
struct ConnectionsPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw
    @Query(sort: \Page.updatedAt, order: .reverse) private var pages: [Page]

    var incomingMessage: String
    var incomingIsError: Bool

    private var chromeScheme: ColorScheme {
        VellumPalette.resolvedScheme(appearanceRaw: appearanceRaw, system: colorScheme)
    }

    private var chromeFill: Color { VellumPalette.chrome(for: chromeScheme) }
    private var chromeRow: Color { VellumPalette.chromeRow(for: chromeScheme) }
    private var chromeInk: Color { VellumPalette.onDesk(for: chromeScheme) }
    private var chromeInkSoft: Color { VellumPalette.onDeskSoft(for: chromeScheme) }

    @State private var pickingFiles = false
    @State private var activeSource: ImportSource = .notes
    @State private var message = ""
    @State private var isError = false

    private let sources: [ImportSource] = [.notes, .journal, .notion]

    var body: some View {
        Form {
            Section {
                ForEach(sources, id: \.self) { source in
                    Button {
                        startImport(source)
                    } label: {
                        HStack(alignment: .center, spacing: 12) {
                            ImportSourceMark(source: source)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(source.title)
                                    .font(VellumFonts.page(.editorial, size: 20, relativeTo: .title3))
                                    .foregroundStyle(chromeInk)
                                Text(source.hint)
                                    .font(VellumFonts.page(.book, size: 14, relativeTo: .subheadline))
                                    .foregroundStyle(chromeInkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 8)
                            Text(LibraryLook.bringInTitle)
                                .font(VellumFonts.page(.book, size: 15, relativeTo: .subheadline))
                                .foregroundStyle(VellumPalette.rust)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(chromeInkSoft)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(LibraryLook.bringInTitle) \(source.title). \(source.hint)")
                    .listRowBackground(chromeRow)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ImportCopy.pickHint)
                    Text(ImportCopy.keepsDate)
                    if !message.isEmpty {
                        Text(message)
                            .foregroundStyle(isError ? VellumPalette.rust : chromeInk)
                    }
                    if ImportLook.hasShareExtension {
                        Text(ImportCopy.shareHint)
                    }
                }
                .font(VellumFonts.page(.book, size: 14, relativeTo: .footnote))
                .foregroundStyle(chromeInkSoft)
            }
        }
        .foregroundStyle(chromeInk)
        .scrollContentBackground(.hidden)
        .background(chromeFill.ignoresSafeArea(.container))
        .navigationTitle(SettingsLook.connectionsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(chromeFill, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(chromeScheme, for: .navigationBar)
        .velinAppearance(appearanceRaw)
        .fileImporter(
            isPresented: $pickingFiles,
            allowedContentTypes: ImportPicker.types(for: activeSource),
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                applyImport(BringInFiles.drafts(from: urls, source: activeSource))
            case .failure:
                message = ImportError.unreadable.copy
                isError = true
            }
        }
        .onAppear {
            if !incomingMessage.isEmpty {
                message = incomingMessage
                isError = incomingIsError
            }
        }
        .onChange(of: incomingMessage) { _, next in
            if !next.isEmpty {
                message = next
                isError = incomingIsError
            }
        }
    }

    private func startImport(_ source: ImportSource) {
        DeskHapticsPlay.tick()
        activeSource = source
        pickingFiles = true
    }

    private func applyImport(_ result: Result<[ImportDraft], ImportError>) {
        let existing = pages.map { (title: $0.title, body: $0.body) }
        let outcome = ImportApply.ingest(result, existing: existing, modelContext: modelContext)
        message = outcome.message
        isError = outcome.isError
    }
}

enum DeskLock {
    static let reason = "Unlock the desk."

    static func evaluate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return false
        }
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
        } catch {
            return false
        }
    }
}

enum DeskHapticsPlay {
    static func tick() {
        guard DeskHaptics.shouldPlay(enabled: DeskSettings.haptics()) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

/// Covers the desk until Face ID or the device passcode succeeds.
struct DeskLockCover: View {
    var onUnlock: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppearanceLook.key) private var appearanceRaw = AppearanceLook.defaultRaw

    private var scheme: ColorScheme {
        VellumPalette.resolvedScheme(appearanceRaw: appearanceRaw, system: colorScheme)
    }

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 40)
            Text("Locked")
                .font(VellumFonts.display(size: 28))
                .foregroundStyle(VellumPalette.onDesk(for: scheme))
            Button("Unlock") {
                Task {
                    if await DeskLock.evaluate() {
                        onUnlock()
                    }
                }
            }
            .font(VellumFonts.page(.book, size: 17, relativeTo: .body))
            .foregroundStyle(VellumPalette.onDesk(for: scheme))
            .frame(minHeight: CGFloat(HitTarget.minimum))
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DeskBackdrop()
                .ignoresSafeArea(.container)
        }
        .velinAppearance(appearanceRaw)
    }
}
