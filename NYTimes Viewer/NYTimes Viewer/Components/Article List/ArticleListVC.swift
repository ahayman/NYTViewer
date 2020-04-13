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
  private var layouts: [NSLayoutConstraint] = []
  
  // MARK: View Construction
  
  private lazy var contentPicker = SegmentPicker(segments: ArticleContent.AllCases(), selected: datasource.content).usingAutoLayout()
  private lazy var topSectionPicker = SegmentPicker(segments: ArticleSection.allCases, selected: .home).usingAutoLayout()
  private lazy var latestSectionPicker = SegmentPicker(segments: [LatestSection.all], selected: LatestSection.all).usingAutoLayout()
  private lazy var sharePicker = SegmentPicker(segments: ArticleShareType.allCases, selected: .all).usingAutoLayout()
  private lazy var pickerStack: UIStackView = UIStackView(arrangedSubviews: [self.contentPicker, self.topSectionPicker]).usingAutoLayout()
  private lazy var articles = ArticleCollection<ArticleData>(data: []).usingAutoLayout()
  private lazy var hr = Styles.HR.new().usingAutoLayout()

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
    if traitCollection.userInterfaceStyle == .dark {
      styleColors = DarkColors()
      styleFonts = DarkFonts()
    } else {
      styleColors = LightColors()
      styleFonts = LightFonts()
    }
    view = Styles.Background.new()
    
    [pickerStack, articles, hr].forEach{ view.addSubview($0) }
    
    pickerStack.isLayoutMarginsRelativeArrangement = true
    pickerStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

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
    activeContrainsts()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: updatePickers)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    updateViewConstraints()
    updateStyle()
  }
  
  // MARK: Private
  
  private func updateStyle() {
    if traitCollection.userInterfaceStyle == .dark {
      styleColors = DarkColors()
      styleFonts = DarkFonts()
    } else {
      styleColors = LightColors()
      styleFonts = LightFonts()
    }
    
    Styles.Background.apply(to: view)
    Styles.HR.apply(to: hr)
    
    articles.updateStyle()
    sharePicker.updateStyle()
    topSectionPicker.updateStyle()
    contentPicker.updateStyle()
    latestSectionPicker.updateStyle()
  }
  
  private func activeSubPicker() -> UIView? {
    switch datasource.content {
    case .mostViewed: return nil
    case .latest: return latestSectionPicker
    case .top: return topSectionPicker
    case .mostShared: return sharePicker
    }
  }
  
  private func activeContrainsts() {
    NSLayoutConstraint.deactivate(layouts)
    
    let guide = view.safeAreaLayoutGuide

      pickerStack.axis = .vertical
      pickerStack.spacing = 5.0
      topSectionPicker.layout = .horizontal
      contentPicker.layout = .horizontal
      latestSectionPicker.layout = .horizontal
      sharePicker.layout = .horizontal
      
      layouts = [
        pickerStack.pin(.top, in: guide),
        pickerStack.pin(.leading, in: guide),
        pickerStack.pin(.trailing, in: guide),

        hr.pin(.top, nextTo: pickerStack),
        hr.pin(.height, equals: 1.0),
        hr.pin(.leading, in: guide),
        hr.pin(.trailing, in: guide),

        articles.pin(.top, nextTo: hr),
        articles.pin(.bottom, in: guide),
        articles.pin(.leading, in: guide),
        articles.pin(.trailing, in: guide),
      ]
    
    NSLayoutConstraint.activate(layouts)
  }
  
  /**
   Updates Picker visibility based on the current selection (content picker)
   Will also scroll the visible picker to show selection
   */
  private func updatePickers() {
    switch datasource.content {
    case .latest:
      [topSectionPicker, sharePicker].forEach{
        $0.removeFromSuperview()
        pickerStack.removeArrangedSubview($0)
      }
      pickerStack.addArrangedSubview(latestSectionPicker)
      latestSectionPicker.scrollToSelected()
    case .top:
      [latestSectionPicker, sharePicker].forEach{
        $0.removeFromSuperview()
        pickerStack.removeArrangedSubview($0)
      }
      pickerStack.addArrangedSubview(topSectionPicker)
      topSectionPicker.scrollToSelected()
    case .mostViewed:
      [latestSectionPicker, sharePicker, topSectionPicker].forEach{
        $0.removeFromSuperview()
        pickerStack.removeArrangedSubview($0)
      }
    case .mostShared:
      [topSectionPicker, latestSectionPicker].forEach{
        $0.removeFromSuperview()
        pickerStack.removeArrangedSubview($0)
      }
      pickerStack.addArrangedSubview(sharePicker)
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
