//
//  ArticleViewerVC.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/13/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewerVC : UIViewController, WKNavigationDelegate {
  private let url: URL

  private lazy var webView: WKWebView = WKWebView(frame: .zero)
  
  init(url: URL) {
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    self.view = webView
    webView.navigationDelegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    webView.load(URLRequest(url: url))
  }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard navigationAction.request.url != self.url else {
      decisionHandler(.allow)
      return
    }
    if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
      UIAlertController
        .alert("Open Link?", message: "Would you like to open the link in Safari? This will take you out of the app.\n\n Link: \(url.absoluteString)")
        .action("Open") { UIApplication.shared.open(url) }
        .action("Cancel", style: .cancel)
        .presentOn(self)
      decisionHandler(.cancel)
    } else {
      decisionHandler(.allow)
    }
  }
  
}

