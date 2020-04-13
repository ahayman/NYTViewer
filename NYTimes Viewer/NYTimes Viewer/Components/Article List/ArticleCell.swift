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

private let cellPadding: CGFloat = 5.0
private let thumbnailHeight: CGFloat = 70.0

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
  
  private let header = Styles.CellTitle.new().usingAutoLayout()
  private let byline = Styles.CellSubtitle.new().usingAutoLayout()
  private let thumbnail = Styles.CellImage.new().usingAutoLayout()
  private let content = Styles.CellContent.new().usingAutoLayout()
  private let hr = Styles.HR.new().usingAutoLayout()
  private var data: Data?
  
  // MARK: Configurable Constraints
  private lazy var imageWidth: NSLayoutConstraint = self.thumbnail.pin(.width, equals: .equal(to: thumbnailHeight))
  private lazy var contentWidth: NSLayoutConstraint = self.contentView.pin(.width, equals: 300.0)

  // MARK: Init & Public
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.useAutoLayout()
    contentView.useAutoLayout()
    contentView.clipsToBounds = true
    
    [header, byline, thumbnail, content, hr].forEach{ contentView.addSubview($0) }
    
    let pad: ConstraintEquality = .equal(to: cellPadding)
    let constraints: [NSLayoutConstraint] = [
      contentView.pin(.top, in: self),
      contentView.pin(.leading, in: self),
      contentView.pin(.trailing, in: self),
      contentView.pin(.bottom, in: self),
      contentWidth.with(priority: .veryHigh),

      thumbnail.pin(.top, in: contentView, offset: pad),
      thumbnail.pin(.leading, in: contentView, offset: pad),
      imageWidth,
      thumbnail.pin(.height, to: .width),

      header.pin(.top, in: contentView, offset: pad),
      header.pin(.leading, nextTo: thumbnail, offset: pad),
      header.pin(.trailing, in: contentView, offset: pad),

      byline.pin(.top, nextTo: header, offset: pad),
      byline.pin(.leading, nextTo: thumbnail, offset: pad),
      byline.pin(.trailing, in: contentView, offset: pad),

      content.pin(.top, nextTo: byline, offset: pad),
      content.pin(.leading, nextTo: thumbnail, offset: pad),
      content.pin(.trailing, in: contentView, offset: pad),

      hr.pin(.top, nextTo: content, offset: .greaterEqual(to: cellPadding)),
      hr.pin(.top, nextTo: thumbnail, offset: .greaterEqual(to: cellPadding)),
      hr.pin(.leading, in: contentView, offset: pad),
      hr.pin(.trailing, in: contentView, offset: pad),
      hr.pin(.height, equals: 1.0),
      hr.pin(.bottom, in: contentView),
    ]
    
    constraints.forEach{ $0.priority = .veryHigh } // Keep autolayout from throwing error on cell init
    NSLayoutConstraint.activate(constraints)
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
  
  func updateStyle() {
    Styles.CellTitle.apply(to: header)
    Styles.CellSubtitle.apply(to: byline)
    Styles.CellImage.apply(to: thumbnail)
    Styles.CellContent.apply(to: content)
    Styles.HR.apply(to: hr)
  }

  func update(width: CGFloat) {
    contentWidth.constant = width
    setNeedsUpdateConstraints()
  }
  
  func preferredSize() -> CGSize {
    updateConstraintsIfNeeded()
    layoutIfNeeded()
    return contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
  }

}
