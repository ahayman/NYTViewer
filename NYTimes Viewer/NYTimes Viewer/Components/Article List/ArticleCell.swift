//
//  ArticleCell.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit
import Combine

/**
 The data neccesary to configure a cell.
 In case of the `image`, we require a way to asynchronously
 retrieve the data to prevent premature downloads.
 
 It would be really nice if protocols could be scoped.
 */
protocol ArticleCellData {
  func image() -> AnyPublisher<UIImage, ImageSourceError>
  var validImage: Bool { get }
  var title: String { get }
  var byline: String { get }
  var content: String { get }
}

/**
 Collection Cell used to display an article summary
 (not the whole article, because that wouldn't fit).
 */
class ArticleCell : UICollectionViewCell {
  
  /// Cell configuration data, but scoped properly
  typealias Data = ArticleCellData

  /// Cancelable held while image is being retrieved.
  private var imageCanceller: Cancellable?

  // MARK: View Construction
  
  private let header = Styles.CellTitle.new()
  private let byline = Styles.CellSubtitle.new()
  private let thumbnail = Styles.CellImage.new()
  private let content = Styles.CellContent.new()
  private let hr = Styles.HR.new()
  private var data: Data?

  // MARK: Init & Public
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubviews([header, byline, thumbnail, content, hr])
  }
  
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  /**
   Configure the cell with new data.
   Use `loadImage` == false to prevent the image from loading.
   This can be done for layout sizing (otherwise, the system will attempt to load
   every cell at once, and then cancel them all just as quickly).
   */
  func configure(with data: Data, loadImage: Bool = true) {
    self.data = data
    header.text = data.title
    byline.text = data.byline
    content.text = data.content
    thumbnail.image = nil

    if loadImage {
      imageCanceller = data.image()
        .receive(on: RunLoop.main)
        .sink{ [weak self] (result: Result<UIImage, ImageSourceError>) in
          self?.thumbnail.image = result.value
        }
    }

    setNeedsLayout()
  }
  
  // MARK: Overrides
  
  override func layoutSubviews() {
    contentView.frame = bounds
    layoutIn(frame: contentView.bounds.inset(all: 5.0))
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    layoutIn(frame: CGRect(origin: .zero, size: size))

    let maxY = [header, byline, content, thumbnail, hr].map{ $0.maxY }.max() ?? 0
    return CGSize(width: size.width, height: maxY + 10.0)
  }
  
  // MARK: Private
  
  /**
   We've separated the layout code so that sizing can be accomplished
   using the actual layout code.
   */
  private func layoutIn(frame: CGRect) {
    var rect = frame
    
    if data?.validImage == true {
      thumbnail.frame = rect.slice(.top(70))
    } else {
      thumbnail.frame = .zero
    }
    
    rect = rect.inset(left: 5.0)
    
    [header, byline, content]
      .set(width: rect.width, height: rect.height)
      .sizeToFit()
    
    header.frame = rect.slice(.top(header.height + 2.0))
    byline.frame = rect.slice(.top(byline.height + 4.0))
    content.frame = rect.slice(.top(content.height + 6.0))
    hr.frame = rect.slice(.top(1.0))
  }
  
}
