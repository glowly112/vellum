import UIKit
import WebKit
import Capacitor

/// Thin native shell around the bundled desk: share sheet + keyboard insets.
final class VellumBridgeViewController: CAPBridgeViewController, WKScriptMessageHandler {
    private static let shareHandlerName = "vellumShare"

    override func capacitorDidLoad() {
        super.capacitorDidLoad()
        bridge?.registerPluginInstance(VellumHostPlugin())
        guard let webView else { return }

        webView.configuration.userContentController.add(self, name: Self.shareHandlerName)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.alwaysBounceVertical = false
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == Self.shareHandlerName else { return }
        let body = message.body as? [String: Any]
        let filename = Self.sanitizedFilename(body?["filename"] as? String)
        let text = body?["text"] as? String ?? ""
        shareTextFile(filename: filename, text: text)
    }

    static func isBlockedRemoteHost(_ url: URL) -> Bool {
        let host = (url.host ?? "").lowercased()
        if host.isEmpty { return false }
        // Live Vercel (and any vercel.app host) is login-walled. Local desk only.
        return host == "vercel.app" || host.hasSuffix(".vercel.app")
    }

    private static func sanitizedFilename(_ raw: String?) -> String {
        let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let base = (trimmed as NSString).lastPathComponent
        let cleaned = base
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
        if cleaned.isEmpty { return "page.txt" }
        if cleaned.lowercased().hasSuffix(".txt") { return cleaned }
        return "\(cleaned).txt"
    }

    private func shareTextFile(filename: String, text: String) {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try Data(text.utf8).write(to: url, options: .atomic)
        } catch {
            return
        }

        let item = VellumTextFileItem(fileURL: url)
        let sheet = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = CGRect(
            x: view.bounds.midX,
            y: view.bounds.maxY - 12,
            width: 1,
            height: 1
        )
        present(sheet, animated: true)
    }
}

/// Capacitor maps `shouldOverrideLoad == true` to `WKNavigationActionPolicy.cancel`.
@objc(VellumHostPlugin)
public class VellumHostPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "VellumHostPlugin"
    public let jsName = "VellumHost"
    public let pluginMethods: [CAPPluginMethod] = []

    @objc override func shouldOverrideLoad(_ navigationAction: WKNavigationAction) -> NSNumber? {
        guard let url = navigationAction.request.url else { return nil }
        if VellumBridgeViewController.isBlockedRemoteHost(url) {
            return true
        }
        return nil
    }
}

/// Presents a `.txt` file in the system share sheet (Mail, Files, AirDrop, …).
private final class VellumTextFileItem: NSObject, UIActivityItemSource {
    let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        fileURL
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        fileURL
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        "public.plain-text"
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        fileURL.lastPathComponent
    }
}
