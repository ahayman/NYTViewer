import UIKit
import WebKit

/**
 A Webview designed to read a single article.
 Any links clicked within the article will be re-directed to Safari.
 */
class ArticleViewerVC : UIViewController, WKNavigationDelegate {
  
  private let url: URL
  private lazy var webView: WKWebView = WKWebView(frame: .zero)
  
  init(url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func loadView() {
    self.view = webView
    webView.navigationDelegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    webView.load(URLRequest(url: url))
  }
  
  /// Used primarily to redirect users to Safari if they click on a link.
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard navigationAction.request.url != self.url else {
      decisionHandler(.allow)
      return
    }
    if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
      UIAlertController
        .alert("Open Link?", message: "Would you like to open the link in Safari?\n\n Link: \(url.absoluteString)")
        .action("Open") { UIApplication.shared.open(url) }
        .action("Cancel", style: .cancel)
        .presentOn(self)
      decisionHandler(.cancel)
    } else {
      decisionHandler(.allow)
    }
  }
  
}

