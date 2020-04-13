import UIKit
import Combine

private let cellReuseId = "ArticleCellReuseId"
private let padding: CGFloat = 5.0

/**
 A collection of Article cells
 The layout will change depending on the size of the view
 */
class ArticleCollection<T: ArticleCellData> : UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  private var data: [T]
  
  /**
   Set this to respond to attempts to refresh the data (pull-down)
   If this isn't set, pulling down to refresh will immediately cancel
   */
  var onRefresh: (() -> Void)?
  
  /**
   Responds to selection of an article.
   */
  var onSelect: ((IndexPath, T) -> Void)?
  
  /// A cell kept in place purely for the purposes of sizing it for layout
  private var sizingCell = ArticleCell(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
  
  // MARK: View Construction

  /// Refresh control.  Is added to the collection view to enable pull-to-refresh
  private lazy var refresh: UIRefreshControl = {
    let control = Styles.RefreshIndicator.new()
    control.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
    return control
  }()

  /// Handle refresh action (pull-to-refresh)
  @objc dynamic private func refreshAction() {
    if let onRefresh = self.onRefresh {
      onRefresh()
    } else {
      refresh.endRefreshing()
    }
  }
  
  private lazy var flowLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    return layout
  }()
  
  private var cellWidth: CGFloat = 300.0

  private lazy var articleCollection: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
    cv.backgroundColor = styleColors.background
    cv.delegate = self
    cv.dataSource = self
    cv.alwaysBounceVertical = true
    cv.register(ArticleCell.self, forCellWithReuseIdentifier: cellReuseId)
    return cv
  }()
  
  // MARK: Init & Public
  
  init(data: [T]) {
    self.data = data
    super.init(frame: .zero)
    self.addSubview(articleCollection)
    articleCollection.addSubview(refresh)
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  /**
   Manually set the loading/refresh indicator.
   Use to keep the UI in sync with data loading.
   Should be set to false after user triggers a pull-to-refresh
   */
  func setLoading(_ loading: Bool) {
    switch (loading, refresh.isRefreshing) {
    case (false, true): refresh.endRefreshing()
    case (true, false): refresh.beginRefreshing()
    default: break
    }
  }
  
  /**
   Update the data.
   Collection will be reloaded with the new data.
   */
  func update(with data: [T]) {
    self.data = data
    articleCollection.reloadData()
  }
  
  func updateStyle() {
    articleCollection.backgroundColor = styleColors.background
    articleCollection.visibleCells
      .compactMap{ $0 as? ArticleCell }
      .forEach{ $0.updateStyle() }
  }

  // MARK: Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    articleCollection.frame = self.bounds
    if bounds.width > 800 {
      let partitions = floor(CGFloat(bounds.width / 400))
      cellWidth = bounds.width / partitions - ((partitions - 1) * padding)
    } else {
      cellWidth = bounds.width
    }
    flowLayout.invalidateLayout()
  }

  // MARK: CollectionView and Layout Delegates
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as? ArticleCell ?? ArticleCell()
    cell.update(width: cellWidth)
    cell.configure(with: data[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    onSelect?(indexPath, data[indexPath.row])
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    sizingCell.configure(with: data[indexPath.row], loadImage: false)
    sizingCell.update(width: cellWidth)
    return sizingCell.preferredSize()
  }
}
