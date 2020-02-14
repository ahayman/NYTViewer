//
//  ArticleListVC.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/11/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit
import Combine

extension ArticleContent : SegmentItem {
  static func AllCases() -> [ArticleContent] {
    return [
      .top(section: .home),
      .latest(section: .all),
      .mostViewed,
      .mostShared(type: .all)
    ]
  }
}
extension ArticleSection : SegmentItem { }
extension ArticleShareType : SegmentItem { }
extension LatestSection : SegmentItem {
  var displayName: String {
    switch self {
    case .all: return "All"
    case let .section(_, displayName): return displayName
    }
  }
  
  
}

/**
 Private struct to convert the article data received from the datasource,
 and convert it into something that can be used by UI (conforming to ArticleCellData)
 
 ImageDatasource is required to retrieve images from the URLs provided by the articles
 */
private struct ArticleData: ArticleCellData  {
  let article: Article
  let datasource: ImageDatasource
  
  /// Retrieve an imageURL if one exists in the media
  private var imageURL: URL? {
    guard let imageUrl = article.media?.first(where: { $0.type == "image" }) else { return nil }
    return URL(string: imageUrl.url)
  }
  
  /// whether a valid Image is available
  var validImage: Bool {
    return imageURL == nil ? false : true
  }
  
  /**
   Retrieve an image from the image datasource, or return error is the URL isn't valid.
   */
  func image() -> AnyPublisher<UIImage, ImageSourceError> {
    guard let url = imageURL else {
      return Future(error: ImageSourceError.NoImageAvailable).eraseToAnyPublisher()
    }
    return datasource
      .getImage(for: url)
      .mapError { ImageSourceError.APIError($0) }
      .eraseToAnyPublisher()
  }
  var title: String { return article.title }
  var byline: String { return article.byline ?? "" }
  var content: String { return article.abstract ?? "" }
}

// The datasource needed to get/update article selection.
protocol ArticleListDatasource {
  /**
   Set Article Content to update the articles.
   Note: This may result in multiple updates to articles if a cache is available
  */
  var content: ArticleContent { get set }

  /// Subscribe to loading to be notified when articles are loading
  var loading: Published<Bool>.Publisher { get }

  /// Subscribe to the articles to get the latest
  var articles: Published<[Article]>.Publisher { get }
  
  /**
   Sections for the "Latest" must be first downloaded.
   Subscribe to this when they're updated.
   */
  var latestSections: Published<[LatestSection]>.Publisher { get }
  
  /// Needed to manually reload data when user pulls-to-refresh.  Also used on first-load.
  func reloadContent()
}

/// Routes that can triggered from this VC
protocol ArticleListRouter : class {
  func routeTo(article: Article)
}

/**
 Primary view controller used to display Article lists
 It contains several content pickers, allowing the user to choose between different
 types of articles (Top, Shared, etc).
 Below the picker is the collection of articles.
 */
class ArticleListVC : UIViewController {
  
  typealias Datasource = ArticleListDatasource
  typealias Router = ArticleListRouter

  private weak var router: Router?
  private var datasource: Datasource
  private let imageSource: ImageDatasource
  
  private var cancellables: [AnyCancellable] = []
  
  // MARK: View Construction
  
  private lazy var contentPicker = SegmentPicker(segments: ArticleContent.AllCases(), selected: datasource.content)
  private lazy var topSectionPicker = SegmentPicker(segments: ArticleSection.allCases, selected: .home)
  private lazy var latestSectionPicker = SegmentPicker(segments: [LatestSection.all], selected: LatestSection.all)
  private lazy var sharePicker = SegmentPicker(segments: ArticleShareType.allCases, selected: .all)
  private lazy var articles = ArticleCollection<ArticleData>(data: [])
  private lazy var hr = Styles.HR.new().setShadow()

  // MARK: Init
  
  init(router: Router, datasource: Datasource, imageSource: ImageDatasource) {
    self.router = router
    self.datasource = datasource
    self.imageSource = imageSource
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  // MARK: Overrides
  
  override func loadView() {
    view = Styles.Background.new()
    view.addSubviews(contentPicker, topSectionPicker, latestSectionPicker, sharePicker, articles, hr)
    
    topSectionPicker.layout = .horizonal(.start)
    latestSectionPicker.layout = .horizonal(.start)

    setupContentStreams()
    setupPickers()
    updatePickers()

    articles.onSelect = { [weak self] (_, article) in
      self?.router?.routeTo(article: article.article)
    }
    articles.onRefresh = { [weak self] in
      self?.datasource.reloadContent()
    }
    datasource.reloadContent()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    var rect = view.safeBounds
    
    contentPicker.frame = rect.slice(.top(40)).inset(left: 5.0, right: 5.0)
    if datasource.content != .mostViewed {
      [topSectionPicker, sharePicker, latestSectionPicker].set(frame: rect.slice(.top(40)).inset(left: 5.0, right: 5.0))
    }
    hr.frame = rect.slice(.top(1))
    articles.frame = rect
  }
  
  override func viewDidLayoutSubviews() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: updatePickers)
  }
  
  // MARK: Private
  
  /**
   Updates Picker visibility based on the current selection (content picker)
   Will also scroll the visible picker to show selection
   */
  private func updatePickers() {
    switch datasource.content {
    case .latest:
      [topSectionPicker, sharePicker].hide()
      latestSectionPicker.isHidden = false
      latestSectionPicker.scrollToSelected()
    case .top:
      [latestSectionPicker, sharePicker].hide()
      topSectionPicker.isHidden = false
      topSectionPicker.scrollToSelected()
    case .mostViewed:
      [latestSectionPicker, sharePicker, topSectionPicker].hide()
    case .mostShared:
      [topSectionPicker, latestSectionPicker].hide()
      sharePicker.isHidden = false
      sharePicker.scrollToSelected()
    }
  }
  
  /**
   Register with datasource publishers to keep the UI updated
   and synced with the datasource.
   */
  private func setupContentStreams() {
    cancellables += datasource.articles
      .receive(on: RunLoop.main)
      .sink { [weak self] (articles: [Article]) in
        guard let this = self else { return }
        this.articles.update(with: articles.map{ ArticleData(article: $0, datasource: this.imageSource)} )
      }
    
    cancellables += datasource.loading
      .receive(on: RunLoop.main)
      .dropFirst()
      .removeDuplicates()
      .sink { [weak self] (loading: Bool) in
        self?.articles.setLoading(loading)
      }
    
    cancellables += datasource.latestSections
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .sink{ [weak self] (sections: [LatestSection]) in
        guard let this = self else { return }
        let selected = sections.first{ $0 == this.latestSectionPicker.selectedItem } ?? .all
        this.latestSectionPicker.load(segments: sections, selected: selected)
      }
  }
  
  
  /**
   Register with each Picker selection changes.
   */
  private func setupPickers() {
    cancellables += contentPicker.selectedSegment
      .receive(on: RunLoop.main)
      .dropFirst()
      .removeDuplicates()
      .sink { [weak self] (content: ArticleContent) in
        guard let this = self else { return }
        let orig = this.datasource.content
        
        switch (orig, content) {
        case (.latest, .latest), (.mostShared, .mostShared), (.mostViewed, .mostViewed), (.top, .top): return
        case (_, .latest): this.datasource.content = .latest(section: this.latestSectionPicker.selectedItem)
        case (_, .mostShared): this.datasource.content = .mostShared(type: this.sharePicker.selectedItem)
        case (_, .mostViewed): this.datasource.content = .mostViewed
        case (_, .top): this.datasource.content = .top(section: this.topSectionPicker.selectedItem)
        }

        UIView.animate(withDuration: 0.1) {
          this.updatePickers()
          this.viewWillLayoutSubviews()
        }
      }

    cancellables += latestSectionPicker.selectedSegment
      .receive(on: RunLoop.main)
      .dropFirst()
      .removeDuplicates()
      .sink { [weak self] (section: LatestSection) in
        guard let this = self else { return }
        if case .latest = this.datasource.content {
          this.datasource.content = .latest(section: section)
        }
      }
    
    cancellables += topSectionPicker.selectedSegment
      .receive(on: RunLoop.main)
      .dropFirst()
      .removeDuplicates()
      .sink { [weak self] (section: ArticleSection) in
        guard let this = self else { return }
        if case .top = this.datasource.content {
          this.datasource.content = .top(section: section)
        }
      }
    
    cancellables += sharePicker.selectedSegment
      .receive(on: RunLoop.main)
      .dropFirst()
      .removeDuplicates()
      .sink { [weak self] (share: ArticleShareType) in
        guard let this = self else { return }
        if case .mostShared = this.datasource.content {
          this.datasource.content = .mostShared(type: share)
        }
      }
  }

}
