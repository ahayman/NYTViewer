//
//  MainRouter.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/12/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

/// Using the NYTClient as the datasource, relying on URLCache for caching the images.
extension NYTClient : ImageDatasource {}

/**
 The main router is responsible for the composition of ViewControllers and the initial
 load into UIWIndow.
 
 This is a type of UI Composer.
 */
class MainRouter {
  
  /// The nav is the root controller
  private let nav: UINavigationController
  
  private let api: APIClient
  private let imageDatasource: ImageDatasource
  private let articleDatasource: ArticleListDatasource
  
  init() {
    let client = NYTClient()
    self.api = client
    self.imageDatasource = client
    self.articleDatasource = ArticleListController(apiClient: api)
    self.nav = UINavigationController()
  }
  
  func load(into window: UIWindow) {
    nav.viewControllers = [newArticleList()]
    window.rootViewController = nav
  }
  
  private func newArticleList() -> UIViewController {
    let vc = ArticleListVC(router: self, datasource: articleDatasource, imageSource: imageDatasource)
    vc.title = "NYT Viewer"
    return vc
  }
  
}

extension MainRouter : ArticleListRouter {
  func routeTo(article: Article) {
    UIAlertController
      .alert("Not Implemented", message: "Cannot show article: \(article.title)")
      .ok()
      .presentOn(nav)
  }
  
  
}
