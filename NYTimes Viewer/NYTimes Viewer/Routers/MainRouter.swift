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
  
  private func newArticleView(for article: Article) -> UIViewController? {
    guard let url = URL(string: article.url) else {
      UIAlertController
        .alert("Invalid", message: "The article URL was invalid and cannot be loaded.")
        .ok()
        .presentOn(nav)
      return nil
    }
    let vc = ArticleViewerVC(url: url)
    vc.title = article.title
    return vc
  }
  
}

extension MainRouter : ArticleListRouter {
  func routeTo(article: Article) {
    guard let vc = newArticleView(for: article) else { return }
    nav.pushViewController(vc, animated: true)
  }
  
  
}
