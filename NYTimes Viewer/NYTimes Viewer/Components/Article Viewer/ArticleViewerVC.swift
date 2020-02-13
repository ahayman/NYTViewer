//
//  ArticleViewerVC.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/13/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewerVC : UIViewController {
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
  }

  override func viewDidAppear(_ animated: Bool) {
    webView.load(URLRequest(url: url))
  }
  
}
