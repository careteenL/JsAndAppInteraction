import UIKit
import WebKit

class BaseWKWebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView = WKWebView(frame: self.view.bounds)
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)

        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        let request = URLRequest(url: url)
        self.webView.load(request)

        self.webView.configuration.userContentController.add(self, name: "login")
        self.webView.configuration.userContentController.add(self, name: "follow")
        self.webView.configuration.userContentController.add(self, name: "comment")
    }

    deinit {
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "login")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "follow")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "comment")
    }

    //
    lazy var actions: [String: ((Any) -> Void)] = [
        "login": {[weak self] json in self?.login(json)},
        "follow": {[weak self] json in self?.follow(json)},
        "comment": {[weak self] json in self?.comment(json)},
    ]

    func login(_ json: Any) {
        print("login")

        guard let jsonString = json as? String, let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as AnyObject {
            if let callBack = jsonObject["cb"] as? String {
                self.webView.evaluateJavaScript("HFWVBridge.runJS('\(callBack)')", completionHandler: nil)
            }
        }
    }

    func follow(_ json: Any) {
        print("follow")
    }

    func comment(_ json: Any) {
        print("comment")
    }

    //WKUIDelegate
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "done", style: .cancel, handler: {_ in completionHandler()}))
        self.present(alertController, animated: true, completion: nil)
    }

    //WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("userContentController didReceive message")
        self.actions[message.name]?(message.body)
    }
}
