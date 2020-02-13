//
//  SegmentPicker.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/11/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

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
class SegmentPicker<T: SegmentItem> : BaseView {
  enum Layout {
    case vertical(Alignment)
    case horizonal(Alignment)
  }
  
  private typealias Segment = (item: T, view: LabelledButton)
  
  private var segments: [Segment]
  @Published private var selected: T
  private let scroll: UIScrollView = UIScrollView(frame: .zero)
  
  /// Register for changes in the selected segment
  var selectedSegment: Published<T>.Publisher { return $selected }
  var selectedItem: T { return selected }

  /**
   Set/change the layout of the segments
   */
  var layout: Layout = .horizonal(.center) {
    didSet { setNeedsLayout() }
  }
  func set(layout: Layout) -> Self {
    self.layout = layout
    return self
  }

  /**
   Initialize with an array of Segments and indicate the selected item.
   */
  init(segments: [T], selected: T) {
    
    let segmentViews: [Segment] = segments.map {
      let button = $0 == selected ? Styles.SegmentSelected.new() : Styles.SegmentUnselected.new()
      button.text = $0.displayName
      return ($0, button)
    }
    
    self.segments = segmentViews
    self.selected = selected
    
    super.init(frame: .zero)
    
    for segment in self.segments {
      let item = segment.item
      segment.view.onPress = { [weak self] in
        self?.onPress(item: item)
      }
    }
    
    addSubview(scroll)
    scroll.addSubviews(self.segments.map{ $0.view })
    updateStyle()
  }
  
  /// I despise this requirement
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
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
  
  private func updateStyle() {
    // Apply appropriate selection styles
    for (item, view) in segments {
      if item == selected {
        Styles.SegmentSelected.apply(to: view)
      } else {
        Styles.SegmentUnselected.apply(to: view)
      }
    }
    
  }
  
  override func layoutSubviews() {
    scroll.frame = bounds
    let rect = scroll.bounds.inset(all: 3.0)
    let views: [UIView] = self.segments.map{ $0.1 }
    
    // Layout Views
    switch layout {
    case .vertical(let justify):
      views
        .set(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        .sizeToFit()
      rect.layoutViews(views, direction: .vertical, margin: 5.0, align: .center, justify: justify)
      scroll.contentSize = bounds.size.set(height: views.reduce(CGFloat(0)) {max($0, $1.maxY)} )
    case .horizonal(let justify):
      views
        .set(width: CGFloat.greatestFiniteMagnitude, height: bounds.height)
        .sizeToFit()
      rect.layoutViews(views, direction: .horizontal, margin: 5.0, align: .center, justify: justify)
      scroll.contentSize = bounds.size.set(width: views.reduce(CGFloat(0)) {max($0, $1.maxX)} )
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
