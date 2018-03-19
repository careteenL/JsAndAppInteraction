import UIKit
import JavaScriptCore

@objc protocol JavaScriptSwiftDelegate: JSExport {

    func login(_ json: Any?)
    func share(_ content: [String: Any])
}

class ViewController: UIViewController, UIWebViewDelegate, JavaScriptSwiftDelegate {

    var webView: UIWebView!
    var jsContext: JSContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView = UIWebView(frame: self.view.bounds);
        self.webView.delegate = self
        self.view.addSubview(self.webView)

        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        //let url = URL(string: "http://home.focus.cn/decoration/picture/3a50f03642e1574931286d670e0557bf.html")!
        let request = URLRequest(url: url)
        self.webView.loadRequest(request)

        let button = UIButton(type: .system)
        button.frame = CGRect(x: 10, y: 400, width: 100, height: 40)
        button.setTitle("NativeButton", for: .normal)
        button.addTarget(self, action: #selector(self.executeJSCode), for: .touchUpInside)
        self.view.addSubview(button)
    }

    func executeJSCode() {
        let wk = BaseWKWebViewController()
        self.present(wk, animated: false, completion: nil)
    }

    //UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")

        self.jsContext = nil
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")

        self.jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        self.jsContext?.setObject(self, forKeyedSubscript: "NativeApp" as (NSCopying & NSObjectProtocol)!)

        /*
        let action: @convention(block) () -> Void = {
            print("123456")
        }
        self.jsContext?.setObject(action, forKeyedSubscript: "jsFunc" as (NSCopying & NSObjectProtocol)!)
        */
    }

    //JavaScriptSwiftDelegate
    func login(_ json: Any?) {
        print("call login method \(json ?? "nil")")

        guard let jsonString = json as? String, let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as AnyObject {
            if let callBack = jsonObject["cb"] as? String {
                let _ = self.jsContext?.evaluateScript("HFWVBridge.runJS('\(callBack)')")
            }
        }
    }

    func share(_ content: [String : Any]) {
        print("call share method \(content)")
    }
}
