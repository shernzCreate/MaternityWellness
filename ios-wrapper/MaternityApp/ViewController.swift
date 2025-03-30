import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        webConfiguration.allowsInlineMediaPlayback = true
        
        // Add user preferences and settings to local storage
        let contentController = WKUserContentController()
        let scriptSource = """
        window.isNativeApp = true;
        window.isiOSApp = true;
        
        // Add iOS specific class to html element for CSS targeting
        document.addEventListener('DOMContentLoaded', function() {
            document.documentElement.classList.add('native-app', 'ios-app');
        });
        """
        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the JavaScript bridge
        setupJavaScriptBridge()
        
        // For development, load from localhost
        // For production, this would load from a bundled web application or from a server
        if let url = URL(string: "http://localhost:5000") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        // Add observer for network activity
        NotificationCenter.default.addObserver(self, selector: #selector(networkActivityChanged(_:)), name: NSNotification.Name(rawValue: "networkActivityChanged"), object: nil)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Handle error - maybe show an error page
    }
    
    // MARK: - WKUIDelegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    // MARK: - Notifications
    
    @objc func networkActivityChanged(_ notification: Notification) {
        if let isActive = notification.userInfo?["isActive"] as? Bool {
            UIApplication.shared.isNetworkActivityIndicatorVisible = isActive
        }
    }
    
    // Bridge for JavaScript <-> Native communication
    func setupJavaScriptBridge() {
        let contentController = webView.configuration.userContentController
        contentController.add(self, name: "nativeBridge")
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nativeBridge" {
            // Handle messages from JavaScript
            guard let messageBody = message.body as? [String: Any] else { return }
            
            if let action = messageBody["action"] as? String {
                switch action {
                case "notification":
                    if let title = messageBody["title"] as? String,
                       let body = messageBody["body"] as? String {
                        showNotification(title: title, body: body)
                    }
                case "share":
                    if let content = messageBody["content"] as? String {
                        shareContent(content)
                    }
                case "openSettings":
                    openAppSettings()
                default:
                    print("Unknown action: \(action)")
                }
            }
        }
    }
    
    // MARK: - Native Features
    
    func showNotification(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func shareContent(_ content: String) {
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Deep Linking Navigation
    
    func navigateToPath(_ path: String) {
        // Navigate to specific path in the web app
        let script = """
        if (window.location.pathname !== '\(path)') {
            window.location.pathname = '\(path)';
        }
        """
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
}