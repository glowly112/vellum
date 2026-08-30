import UIKit
import UniformTypeIdentifiers

/// Share to Velin. Writes an inbox, then opens the desk. No accounts.
final class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0xF3 / 255, green: 0xEB / 255, blue: 0xDD / 255, alpha: 1)
        let label = UILabel()
        let serif = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
            .withDesign(.serif)
        label.font = UIFont(descriptor: serif ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2), size: 22)
        label.text = "Bringing into Velin…"
        label.textColor = UIColor(red: 0x2C / 255, green: 0x24 / 255, blue: 0x19 / 255, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        collectAndSend()
    }

    private func collectAndSend() {
        let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
            .flatMap { $0.attachments ?? [] }
        Task {
            var inbox: [ImportInboxItem] = []
            for provider in providers {
                if let item = await load(provider) {
                    inbox.append(item)
                }
            }
            if !inbox.isEmpty {
                _ = ImportInbox.write(inbox)
            }
            await MainActor.run {
                if !inbox.isEmpty {
                    openHost(ImportInbox.payloadURL(items: inbox))
                }
                extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    private func load(_ provider: NSItemProvider) async -> ImportInboxItem? {
        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier),
           let url = await loadURL(provider, type: UTType.fileURL.identifier) {
            return loadFile(url)
        }
        if provider.hasItemConformingToTypeIdentifier(UTType.html.identifier),
           let text = await loadText(provider, type: UTType.html.identifier) {
            return textItem(text, name: "")
        }
        if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
           let text = await loadText(provider, type: UTType.plainText.identifier) {
            return textItem(text, name: "")
        }
        if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier),
           let text = await loadText(provider, type: UTType.text.identifier) {
            return textItem(text, name: "")
        }
        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
           let url = await loadURL(provider, type: UTType.url.identifier),
           url.isFileURL {
            return loadFile(url)
        }
        return nil
    }

    private func loadFile(_ url: URL) -> ImportInboxItem? {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        let data = (try? Data(contentsOf: url)) ?? Data()
        let values = try? url.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
        let fileDate = ImportFileDate.pick(creation: values?.creationDate, modification: values?.contentModificationDate)
        switch ImportRead.file(name: url.lastPathComponent, data: data, fileDate: fileDate, source: .file) {
        case .success(let drafts):
            return drafts.first.map(ImportInbox.item(from:))
        case .failure:
            return textItem(
                String(data: data, encoding: .utf8) ?? "",
                name: url.lastPathComponent,
                fileDate: fileDate
            )
        }
    }

    private func textItem(_ text: String, name: String, fileDate: Date? = nil) -> ImportInboxItem? {
        switch ImportRead.textPage(name: name, text: text, fileDate: fileDate, source: .file) {
        case .success(let drafts):
            return drafts.first.map(ImportInbox.item(from:))
        case .failure:
            let parsed = ImportRead.excerpt(name: name, text: text)
            if !ImportRead.hasInk(title: parsed.title, body: parsed.body) {
                return nil
            }
            return ImportInboxItem(
                title: parsed.title,
                body: parsed.body,
                createdAt: parsed.date?.timeIntervalSince1970,
                updatedAt: parsed.date?.timeIntervalSince1970,
                fileDate: fileDate?.timeIntervalSince1970,
                source: ImportSource.file.rawValue
            )
        }
    }

    private func loadText(_ provider: NSItemProvider, type: String) async -> String? {
        guard let item = try? await provider.loadItem(forTypeIdentifier: type) else { return nil }
        if let text = item as? String { return text }
        if let data = item as? Data { return String(data: data, encoding: .utf8) }
        if let attr = item as? NSAttributedString { return attr.string }
        return nil
    }

    private func loadURL(_ provider: NSItemProvider, type: String) async -> URL? {
        guard let item = try? await provider.loadItem(forTypeIdentifier: type) else { return nil }
        if let url = item as? URL { return url }
        if let url = item as? NSURL { return url as URL }
        if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
            return url
        }
        return nil
    }

    /// Share extensions cannot use `extensionContext.open`. Walk responders.
    private func openHost(_ url: URL?) {
        guard let url else { return }
        var responder: UIResponder? = self
        let sel = sel_registerName("openURL:")
        while let current = responder {
            if current.responds(to: sel) {
                current.perform(sel, with: url)
                break
            }
            responder = current.next
        }
    }
}
