import LocalAuthentication
import SwiftUI

private enum SettingsRoute: Hashable {
    case connections
}

/// Paper Settings. Inset grouped chrome on Velin paper — not Notes gray.
struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var openConnections: Bool
    var onPick: (ImportSource) -> Void
    var message: String
    var isError: Bool

    @AppStorage(DeskSettings.lockKey) private var lockDesk = SettingsLook.lockDefault
    @AppStorage(DeskSettings.awakeKey) private var keepAwake = SettingsLook.awakeDefault
    @AppStorage(DeskSettings.hapticsKey) private var haptics = SettingsLook.hapticsDefault
    @AppStorage(DeskSettings.welcomeKey) private var replayWelcome = SettingsLook.welcomeDefault
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Form {
                Section {
                    NavigationLink(SettingsLook.connectionsTitle, value: SettingsRoute.connections)
                        .listRowBackground(VellumPalette.ivory)
                }

                Section(SettingsLook.deskTitle) {
                    Toggle(SettingsLook.lockRow, isOn: $lockDesk)
                        .listRowBackground(VellumPalette.ivory)
                    Toggle(SettingsLook.awakeRow, isOn: $keepAwake)
                        .listRowBackground(VellumPalette.ivory)
                    Toggle(SettingsLook.hapticsRow, isOn: $haptics)
                        .listRowBackground(VellumPalette.ivory)
                    Toggle(SettingsLook.welcomeRow, isOn: $replayWelcome)
                        .listRowBackground(VellumPalette.ivory)
                }

                Section(SettingsLook.aboutTitle) {
                    Text(SettingsLook.aboutCopy)
                        .listRowBackground(VellumPalette.ivory)
                    LabeledContent("Version", value: SettingsLook.versionLabel)
                        .listRowBackground(VellumPalette.ivory)
                }
            }
            .font(VellumFonts.page(.book, size: 17, relativeTo: .body))
            .foregroundStyle(VellumPalette.ink)
            .scrollContentBackground(.hidden)
            .background(VellumPalette.paper.ignoresSafeArea(.container))
            .navigationTitle(SettingsLook.title)
            .navigationBarTitleDisplayMode(.inline)
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
                    onPick: onPick,
                    message: message,
                    isError: isError
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
        .tint(VellumPalette.ink)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(VellumPalette.paper)
    }

    private func confirmLock() async {
        let ok = await DeskLock.evaluate()
        if !ok {
            lockDesk = false
        }
    }
}

/// Named sources on paper. Craft Integrations layout, Velin sources.
struct ConnectionsPage: View {
    var onPick: (ImportSource) -> Void
    var message: String
    var isError: Bool

    private let sources: [ImportSource] = [.notes, .journal, .notion]

    var body: some View {
        Form {
            Section {
                ForEach(sources, id: \.self) { source in
                    Button {
                        DeskHapticsPlay.tick()
                        onPick(source)
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(source.title)
                                    .font(VellumFonts.page(.editorial, size: 20, relativeTo: .title3))
                                    .foregroundStyle(VellumPalette.ink)
                                Text(source.hint)
                                    .font(VellumFonts.page(.book, size: 14, relativeTo: .subheadline))
                                    .foregroundStyle(VellumPalette.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 8)
                            Text(LibraryLook.bringInTitle)
                                .font(VellumFonts.page(.book, size: 15, relativeTo: .subheadline))
                                .foregroundStyle(VellumPalette.rust)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(source.title). \(source.hint)")
                    .listRowBackground(VellumPalette.ivory)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ImportCopy.keepsDate)
                    if !message.isEmpty {
                        Text(message)
                            .foregroundStyle(isError ? VellumPalette.rust : VellumPalette.ink)
                    }
                    Text(ImportCopy.shareHint)
                }
                .font(VellumFonts.page(.book, size: 14, relativeTo: .footnote))
                .foregroundStyle(VellumPalette.inkSoft)
            }
        }
        .scrollContentBackground(.hidden)
        .background(VellumPalette.paper.ignoresSafeArea(.container))
        .navigationTitle(SettingsLook.connectionsTitle)
        .navigationBarTitleDisplayMode(.inline)
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

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 40)
            Text("Locked")
                .font(VellumFonts.display(size: 28))
                .foregroundStyle(VellumPalette.onDesk)
            Button("Unlock") {
                Task {
                    if await DeskLock.evaluate() {
                        onUnlock()
                    }
                }
            }
            .font(VellumFonts.page(.book, size: 17, relativeTo: .body))
            .foregroundStyle(VellumPalette.onDesk)
            .frame(minHeight: CGFloat(HitTarget.minimum))
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            DeskBackdrop()
                .ignoresSafeArea(.container)
        }
    }
}
