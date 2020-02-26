//
//  ArticleCollection.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/11/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

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
  private var sizingCell = ArticleCell(frame: .zero)
  
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

  private lazy var articleCollection: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
  
  // MARK: Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    articleCollection.frame = self.bounds
  }

  // MARK: CollectionView and Layout Delegates
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as? ArticleCell ?? ArticleCell()
    cell.configure(with: data[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    onSelect?(indexPath, data[indexPath.row])
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    sizingCell.configure(with: data[indexPath.row], loadImage: false)
    if bounds.width > 600 {
      let partitions = floor(CGFloat(bounds.width / 300))
      let width: CGFloat = bounds.width / partitions - ((partitions - 1) * padding)
      return sizingCell.sizeThatFits(CGSize(width: width, height: bounds.height))
    } else {
      return sizingCell.sizeThatFits(bounds.size)
    }
  }
}
