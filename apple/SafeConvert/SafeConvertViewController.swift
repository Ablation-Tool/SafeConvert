import AVFoundation
import SwiftUI
import UIKit
import WebKit

final class SafeConvertViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    private var webView: WKWebView!
    private var privacyShield: UIVisualEffectView?
    private let speechSynth = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true
        configuration.websiteDataStore = .default()
        configuration.userContentController.add(self, name: "safeConvertSpeech")
        configuration.userContentController.add(self, name: "zoeSafeSpeech")

        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.accessibilityLabel = "Unit converter"
        view.addSubview(webView)
        installPrivacyShield()

        guard let baseUrl = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "safeconvert") else {
            webView.loadHTMLString("<p>SafeConvert resource is missing.</p>", baseURL: nil)
            return
        }

        let region = SafeBeaconMeshCore.mapIsoCountryToRegion(Locale.current.region?.identifier)
        let lang = SafeBeaconMeshCore.normalizeLangCode(Locale.current.language.languageCode?.identifier)
        let theme = traitCollection.userInterfaceStyle == .dark ? "dark" : "light"

        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "theme", value: theme),
            URLQueryItem(name: "region", value: region),
            URLQueryItem(name: "lang", value: lang),
        ]
        let loadUrl = components?.url ?? baseUrl
        webView.loadFileURL(loadUrl, allowingReadAccessTo: baseUrl.deletingLastPathComponent())
    }

    // MARK: Calm story voice bridge (instant kill on background or EXIT)

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard (message.name == "safeConvertSpeech" || message.name == "zoeSafeSpeech"),
              let body = message.body as? [String: String] else {
            return
        }
        if body["action"] == "stop" {
            speechSynth.stopSpeaking(at: .immediate)
            return
        }
        if body["action"] == "speak", let text = body["text"], !text.isEmpty {
            speechSynth.stopSpeaking(at: .immediate)
            let utterance = AVSpeechUtterance(string: String(text.prefix(2800)))
            utterance.rate = 0.44
            utterance.voice = AVSpeechSynthesisVoice(language: body["lang"] ?? "en-US")
            speechSynth.speak(utterance)
        }
    }

    // MARK: App-switcher privacy shield (mirrors Android FLAG_SECURE)

    private func installPrivacyShield() {
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(coverForBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(uncoverForForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func coverForBackground() {
        speechSynth.stopSpeaking(at: .immediate)
        webView?.evaluateJavaScript("if (typeof exitHelp === 'function') { exitHelp(); }", completionHandler: nil)
        guard privacyShield == nil else { return }
        let shield = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
        shield.frame = view.bounds
        shield.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shield.isAccessibilityElement = false
        view.addSubview(shield)
        privacyShield = shield
    }

    @objc private func uncoverForForeground() {
        privacyShield?.removeFromSuperview()
        privacyShield = nil
    }

    deinit {
        speechSynth.stopSpeaking(at: .immediate)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Media capture (audio/video evidence) only for the bundled local page

    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(origin.protocol == "file" ? .prompt : .deny)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if url.isFileURL {
            decisionHandler(.allow)
            return
        }
        let scheme = url.scheme?.lowercased() ?? ""
        if navigationAction.navigationType == .linkActivated,
           SafeBeaconMeshCore.isAllowedExternalScheme(url.absoluteString) {
            if scheme == "geo" {
                let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                    .queryItems?.first(where: { $0.name == "q" })?.value ?? "hospital"
                let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "hospital"
                if let appleMaps = URL(string: "https://maps.apple.com/?q=" + encoded) {
                    UIApplication.shared.open(appleMaps)
                }
            } else {
                UIApplication.shared.open(url)
            }
        }
        decisionHandler(.cancel)
    }
}

struct SafeConvertView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SafeConvertViewController {
        SafeConvertViewController()
    }

    func updateUIViewController(_ controller: SafeConvertViewController, context: Context) {
    }
}
