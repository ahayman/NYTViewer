import UIKit
import Combine

/**
 Protocol for items provided to the segment picker.
 The requirement `displayName` is used for the segment text.
 The items must be equatable in order to properly select items.
 */
protocol SegmentItem : Equatable {
  var displayName: String { get }
}

/**
 A simple UI that displays a list of segments for the user to pick from.
 Set `onSelect` to be notified of selection changes.
 Segments can be arranged horizontally or vertically (default: horizontal-center)
 If the segments cannot be displayed in the view, the view will scroll.
 */
class SegmentPicker<T: SegmentItem> : UIView {
  
  enum Layout {
    case vertical
    case horizontal
  }
  
  private typealias Segment = (item: T, view: LabelledButton)

  private var segments: [Segment] = []
  @Published private var selected: T
  private let scroll: UIScrollView = UIScrollView(frame: .zero).usingAutoLayout()
  private let stack: UIStackView = UIStackView(arrangedSubviews: []).usingAutoLayout()
  
  /// Register for changes in the selected segment
  var selectedSegment: Published<T>.Publisher { return $selected }
  var selectedItem: T { return selected }

  /**
   Set/change the layout of the segments
   */
  var layout: Layout = .horizontal {
    didSet { updateLayout() }
  }
  var layoutConstraint: NSLayoutConstraint?
  
  func set(layout: Layout) -> Self {
    self.layout = layout
    return self
  }

  /**
   Initialize with an array of Segments and indicate the selected item.
   */
  init(segments: [T], selected: T) {
    self.selected = selected
    
    super.init(frame: .zero)
    
    addSubview(scroll)
    scroll.addSubview(stack)
    
    NSLayoutConstraint.activate([
      scroll.pin(.top, in: self),
      scroll.pin(.bottom, in: self),
      scroll.pin(.leading, in: self),
      scroll.pin(.trailing, in: self),

      stack.pin(.top, in: scroll),
      stack.pin(.bottom, in: scroll),
      stack.pin(.leading, in: scroll, offset: .greaterEqual(to: 0)),
      stack.pin(.centerX, in: scroll).with(priority: .high),
      stack.pin(.trailing, in: scroll),
    ])
    
    load(segments: segments, selected: selected)
  }
  
  /// I despise this requirement
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  /**
   Loads a new set of segments along with a selection
   All prior segments will be replaced with new ones
   */
  func load(segments: [T], selected: T) {
    self.selected = selected
    
    self.segments.forEach{
      stack.removeArrangedSubview($0.view)
      $0.view.removeFromSuperview()
    }
    
    self.segments = segments.map { item in
      let button = (item == selected ? Styles.SegmentSelected.new() : Styles.SegmentUnselected.new()).usingAutoLayout()
      button.text = item.displayName
      button.onPress = { [weak self] in
        self?.onPress(item: item)
      }
      return (item, button)
    }
    
    self.segments.forEach{ stack.addArrangedSubview($0.view) }

    updateLayout()
  }
  
  /**
   Scroll to the selected item to bring it into view.
   If animate == true, then the scroll action is animated.
   */
  func scrollToSelected(animate: Bool = true) {
    guard let view = getSelectedSegment()?.view else { return }
    scroll.scrollRectToVisible(view.frame, animated: animate)
  }
  
  /**
   Scrolls to the item provided, so long as it's in initial segments provided.
   Calling this will not trigger the `onSelect` to be called.
   If scroll == true, then it will animate and scroll to the selected item
   Note: If you want to scroll without animation, set scroll to false and manually call `scrollToSelected(animate: false)`
   */
  func select(item: T, scroll: Bool = true) {
    guard let select = self.segments.first(where: { $0.item == item })?.item else { return }
    selected = select
    updateStyle()
    if scroll { scrollToSelected() }
  }
  
  private func updateLayout() {
    
    NSLayoutConstraint.deactivate([layoutConstraint].compactMap{$0})

    switch layout {
    case .horizontal:
      stack.axis = .horizontal
      stack.distribution = .fillProportionally
      stack.spacing = 5.0
      layoutConstraint = stack.heightAnchor.constraint(equalTo: scroll.heightAnchor)
    case .vertical:
      stack.axis = .vertical
      stack.distribution = .fillProportionally
      stack.spacing = 5.0
      layoutConstraint = stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
    }
    
    NSLayoutConstraint.activate([layoutConstraint].compactMap{$0})
  }

  /// Apply appropriate selection styles
  func updateStyle() {
    for (item, view) in segments {
      if item == selected {
        Styles.SegmentSelected.apply(to: view)
      } else {
        Styles.SegmentUnselected.apply(to: view)
      }
    }
  }
  
  /// Retrieves the selected segment
  private func getSelectedSegment() -> Segment? {
    return self.segments.first(where: { $0.item == selected })
  }

  /// Select a item and updates the layout to reflect
  private func onPress(item: T) {
    guard self.segments.first(where: { $0.item == item }) != nil  else { return }
    selected = item
    updateStyle()
  }
  
}
