//
//  CGRect+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

/**
 Placement normally designates a side of a rect along with a margin from that side.
 */
public enum Placement {
  case top(CGFloat)
  case bottom(CGFloat)
  case left(CGFloat)
  case right(CGFloat)
}

/**
 Alignment depends on the context to which it is provided. Normally, this is either vertically or horizontally.
 For vertical alignments, the top == start and bottom == end.
 For horizontal alignments, the left == start and right == end.
 In all other cases (or example, between two points) the alignment start should represent the beginning of the context while
 the end should represent the end of the context.
 */
public enum Alignment {
  case start
  case startOffset(CGFloat)
  case center
  case centerOffset(CGFloat)
  case end
  case endOffset(CGFloat)
  
  var offset: CGFloat { switch self {
    case let .startOffset(offset), let .centerOffset(offset), let .endOffset(offset): return offset
    case .start, .center, .end: return 0
  }}
}

public enum RectDimension {
  case x
  case y
  case width
  case height
  case maxY
  case maxX
}

public enum Direction {
  case vertical
  case horizontal
}

typealias Insets = UIEdgeInsets

extension UIEdgeInsets {
  var horizontal: CGFloat { return left + right }
  var vertical: CGFloat { return top + bottom }
  
  init(horizontal: CGFloat = 0, vertical: CGFloat = 0) {
    self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }
  init(all: CGFloat) {
    self.init(top: all, left: all, bottom: all, right: all)
  }
}

public extension CGRect {
  
  /// Convenience intializer that shortens the syntax and allows you to omit parameters.  Any ommitted parameters will default to 0
  init(x: CGFloat = 0, y: CGFloat = 0, w: CGFloat = 0, h: CGFloat = 0) {
    self.init(x: x, y: y, width: w, height: h)
  }
  
  /// Convenience initializer that shortens the syntax and allows you to specify the Rect in terms of the origin and/or the size.
  init(origin: CGPoint = CGPoint(), size: CGSize = CGSize()) {
    self.init(x: origin.x, y: origin.y, width: size.width, height: size.height)
  }
  
  /// Convenience accessor that allow you grab origin.x
  var x: CGFloat {
    return origin.x
  }
  
  /// Convenience accessor that allow you grab origin.y
  var y: CGFloat {
    return origin.y
  }
  
  /// Chaining Operator that allows you to create a new Rect by setting one or more parameters.  Note: maxX & maxY parameters are applied last and will override width/height
  func set(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil, maxX: CGFloat? = nil, maxY: CGFloat? = nil) -> CGRect {
    var rect = self
    if let x = x { rect.origin.x = x }
    if let y = y { rect.origin.y = y }
    if let width = width { rect.size.width = width }
    if let height = height { rect.size.height = height }
    if let maxX = maxX {
      rect.size.width += maxX - self.maxX
    }
    if let maxY = maxY {
      rect.size.height += maxY - self.maxY
    }
    return rect
  }
  
  /// Chaining Operator that allows you to create a new Rect by setting either the origin or the size
  func set(origin: CGPoint? = nil, size: CGSize? = nil) -> CGRect {
    var rect = self
    if let origin = origin { rect.origin = origin }
    if let size = size { rect.size = size }
    return rect
  }
  
  /// Allows you to adjust a specific dimension of the rect by passing the rect into the adjuster and setting the new rect's dimension to the result.
  func adjust(_ dimension: RectDimension, adjuster: (CGRect) -> CGFloat) -> CGRect {
    var rect = self
    switch dimension {
    case .x: rect.origin.x = adjuster(rect)
    case .y: rect.origin.y = adjuster(rect)
    case .width: rect.size.width = adjuster(rect)
    case .height: rect.size.height = adjuster(rect)
    case .maxY: rect.size.height += adjuster(rect) - self.maxY
    case .maxX: rect.size.width += adjuster(rect) - self.maxX
    }
    return rect
  }
  
  /// Inset the rect on all edges, returns a new rect
  func inset(all inset: CGFloat) -> CGRect {
    return self.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
  }

  /// Inset the rect by one or more sides, returns a new rect
  func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> CGRect {
    return self.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
  }
  
  /// position the rect in another rect
  func align(to ref: CGRect, vertical: Alignment? = nil, horizontal: Alignment? = nil) -> CGRect {
    var rect = self
    if let vertical = vertical {
      switch vertical {
      case .start: rect.origin.y = ref.origin.y
      case .startOffset(let offset): rect.origin.y = ref.origin.y + offset
      case .center: rect.origin.y = ref.midY - (rect.height / 2)
      case .centerOffset(let offset): rect.origin.y = ref.midY - (rect.height / 2) + offset
      case .end: rect.origin.y = ref.maxY - rect.height
      case .endOffset(let offset): rect.origin.y = (ref.maxY - rect.height) + offset
      }
    }
    if let horizontal = horizontal {
      switch horizontal {
      case .start: rect.origin.x = ref.origin.x
      case .startOffset(let offset): rect.origin.x = ref.origin.x + offset
      case .center: rect.origin.x = ref.midX - (rect.width / 2)
      case .centerOffset(let offset): rect.origin.x = ref.midX - (rect.width / 2) + offset
      case .end: rect.origin.x = ref.maxX - rect.width
      case .endOffset(let offset): rect.origin.x = ref.maxX - rect.width + offset
      }
    }
    return rect
  }
  
  /**
   This will place the rect next to the provided rect on the placement side specified. The value of the placement represents the margin
   between this rect and the provided rect.
   If `align` is provided, the rect will be aligned to that rect on the opposite axis with which it was placed. So top/bottom placements allow for horizontal alignment
   and left/right placements allow for vertical alignment.  So, for example, if you place the rect at the `top` of the reference rect and align = '.center',
   the rect will be place above the provided rect and centered horizontally on that rect.
   This will not resize the rect in any fashion.  It only affects placement.
   */
  func place(nextTo ref: CGRect, _ placement: Placement, align: Alignment? = nil) -> CGRect {
    var rect = self
    switch placement {
    case .top(let offset): rect.origin.y = ref.origin.y - (rect.size.height + offset)
    case .bottom(let offset): rect.origin.y = ref.maxY + offset
    case .left(let offset): rect.origin.x = ref.origin.x - (rect.size.width + offset)
    case .right(let offset): rect.origin.x = ref.maxX + offset
    }
    
    if let align = align {
      switch placement {
      case .top, .bottom: rect = rect.align(to: ref, horizontal: align)
      case .left, .right: rect = rect.align(to: ref, vertical: align)
      }
    }
    
    return rect
  }
  
  /**
   Split the rect into two and returns the split in a tuple.
   If you wish to modify instead of splitting, using "slice" instead
  */
  func split(_ placement: Placement) -> (split: CGRect, remaining: CGRect) {
    var rect = self
    let split = rect.slice(placement)
    return (split, rect)
  }

  /**
   Creates a new rect positioned according to the the references offsets from a reference Rect.
   Note: If top & bottom or left & right are both set, then the height & width will be altered to fit the rect.
   */
  func position(in ref: CGRect, top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) -> CGRect {
    var newRect = self
    
    switch (top, bottom) {
    case (.some(let top), .some(let bottom)):
      newRect.origin.y = ref.y + top
      newRect.size.height = ref.height - (top + bottom)
    case (.some(let top), .none):
      newRect.origin.y = ref.y + top
    case (.none, .some(let bottom)):
      newRect.origin.y = ref.maxY - (newRect.size.height + bottom)
    case (.none, .none): break
    }
    
    switch (left, right) {
    case (.some(let left), .some(let right)):
      newRect.origin.x = ref.x + left
      newRect.size.width = ref.width - (left + right)
    case (.some(let left), .none):
      newRect.origin.x = ref.x + left
    case (.none, .some(let right)):
      newRect.origin.x = ref.maxX - (newRect.size.width + right)
    case (.none, .none): break
    }
    
    return newRect
  }
  
  /**
   Distributes the provided rects within this rect and returns a new array of rects distributed with an equal margin.
   Margin between each item is calculated as the same, no matter the size of each rect.  It's recommended that the total height
   of all rects be less than the height of this rect, or the returned rects may overlap.
   If `spaceAround` is specified, then the rects will be distributed with an equal margin around the first and last rects.
   If `align` is specified, then the rects will be aligned on the opposing axis they are distributed along
   */
  func distribute(direction: Direction, rects: [CGRect], align: Alignment? = nil, spaceAround: Bool = false) -> [CGRect] {
    guard rects.count > 0 else { return [] }
    guard rects.count > 1 else {
      let alignment: Alignment = spaceAround ? .center : .start
      switch direction {
      case .horizontal: return [rects[0].align(to: self,horizontal: alignment)]
      case .vertical: return [rects[0].align(to: self, vertical: alignment)]
      }
    }
    
    let countOff = spaceAround ? 1 : -1
    var newRects = [CGRect]()
    switch direction {
    case .vertical:
      let margin: CGFloat = (height - rects.reduce(0, { $0 + $1.height })) / CGFloat(rects.count + countOff)
      var marker = spaceAround ? self.y + margin : self.y
      for var rect in rects {
        rect.origin.y = marker
        marker = rect.maxY + margin
        if let align = align {
          rect = rect.align(to: self, horizontal: align)
        }
        newRects.append(rect)
      }
    case .horizontal:
      let margin: CGFloat = (width - rects.reduce(0, { $0 + $1.width })) / CGFloat(rects.count + countOff)
      var marker = spaceAround ? self.x + margin : self.x
      for var rect in rects {
        rect.origin.x = marker
        marker = rect.maxX + margin
        if let align = align {
          rect = rect.align(to: self, vertical: align)
        }
        newRects.append(rect)
      }
    }
    
    return newRects
  }
  
  /**
   This will distribute an array of views in the direction provided, distributed with an equal margin between them.
   This uses the `distribute(... rects:)` function underneath.
   If `sized` is provided, all of the views will be re-sized to the provided size.
   Both `align` and `spaceAround` have the same effect as they do when distributing rects: `align` will align on the opposing axis and
   `spaceAround` will add margins around the the first/last views.
   */
  func distributeViews(_ views: [UIView], direction: Direction, sized: CGSize? = nil, align: Alignment? = nil, spaceAround: Bool = false) {
    var rects: [CGRect] = views.map{
      var rect = $0.frame
      if let size = sized {
        rect.size = size
      }
      return rect
    }
    rects = self.distribute(direction: direction, rects: rects, align: align, spaceAround: spaceAround)
    views.forEach{ $0.frame = rects.removeFirst() }
  }
  
  /**
   This will layout a set of provided rects inside this Rect.  It's different from `distribute` in that while distribute will distribute the provided Rects evenly in the space of this Rect,
   layout will layout each rect with a specified margin between each rect.
   - Parameters:
   - rects: An array of rects to be laid out
   - direction: The direction the rects should be laid out (vertical or horizontal)
   - margin: The margin between each rect
   - align: How to align each rect on the _opposite_ axis the rects are laid out on.  If `nil`, the rects won't be aligned (the opposing axis will be left alone)
   - justify: Where to begin laying out the rects (how the content is justified).  By default, it will begin at the start of the layout axis.  For .center and .end justifications
   the calculated height of all rects (plus margin) will be used to center/end all content.
   - Returns: A array of new rects that have been laid out.
   */
  
  func layout(rects: [CGRect], direction: Direction, margin: CGFloat, align: Alignment? = nil, justify: Alignment = .start) -> [CGRect] {
    var newRects = [CGRect]()
    switch (direction) {
      
    case .vertical:
      var mark: CGFloat
      switch justify {
      case .start: mark = self.y
      case .startOffset(let offset): mark = self.y + offset
      case .center:
        let tHeight = rects.reduce(-margin) { $0 + $1.height + margin }
        mark = self.midY - tHeight / 2
      case .centerOffset(let offset):
        let tHeight = rects.reduce(-margin) { $0 + $1.height + margin }
        mark = (self.midY - tHeight / 2) + offset
      case .end:
        let tHeight = rects.reduce(-margin) { $0 + $1.height + margin }
        mark = self.maxY - tHeight
      case .endOffset(let offset):
        let tHeight = rects.reduce(-margin) { $0 + $1.height + margin }
        mark = self.maxY - (tHeight + offset)
      }
      for var rect in rects {
        rect.origin.y = mark
        if let align = align {
          rect = rect.align(to: self, horizontal: align)
        }
        newRects.append(rect)
        mark += rect.size.height + margin
      }
      
    case .horizontal:
      var mark: CGFloat
      switch justify {
      case .start: mark = self.x
      case .startOffset(let offset): mark = self.x + offset
      case .center:
        let tWidth = rects.reduce(-margin) { $0 + $1.width + margin }
        mark = self.midX - tWidth / 2
      case .centerOffset(let offset):
        let tWidth = rects.reduce(-margin) { $0 + $1.width + margin }
        mark = (self.midX - tWidth / 2) + offset
      case .end:
        let tWidth = rects.reduce(-margin) { $0 + $1.width + margin }
        mark = self.maxX - tWidth
      case .endOffset(let offset):
        let tWidth = rects.reduce(-margin) { $0 + $1.width + margin }
        mark = self.maxX - (tWidth + offset)
      }
      for var rect in rects {
        rect.origin.x = mark
        if let align = align {
          rect = rect.align(to: self, vertical: align)
        }
        newRects.append(rect)
        mark += rect.size.width + margin
      }
    }
    
    return newRects
  }
  
  /**
   This will layout a set of views inside this Rect.  It's different from `distribute` in that while distribute will distribute the provided Views evenly in the space of this Rect,
   layout will layout each View with a specified margin between each rect.
   - Parameters:
   - views: An array of views to be laid out
   - direction: The direction the rects should be laid out (vertical or horizontal)
   - margin: The margin between each rect
   - sized: An optional size that will resize each view to the provided size before laying them out.
   - align: How to align each view on the _opposite_ axis the rects are laid out on.  If `nil`, the rects won't be aligned (the opposing axis will be left alone)
   - justify: Where to begin laying out the rects (how the content is justified).  By default, it will begin at the start of the layout axis.  For .center and .end justifications
   the calculated height of all rects (plus margin) will be used to center/end all content.
   - Returns: The bounding rect used up during the layout
   */
  @discardableResult func layoutViews(_ views: [UIView], direction: Direction, margin: CGFloat = 0, sized: CGSize? = nil, align: Alignment? = nil, justify: Alignment = .start) -> CGRect {
    var rects: [CGRect] = views.map{
      var rect = $0.frame
      if let size = sized {
        rect.size = size
      }
      return rect
    }
    rects = self.layout(rects: rects, direction: direction, margin: margin, align: align, justify: justify)
    views.zip(rects).forEach{ $0.frame = $1 }
    if (rects.count > 0) {
      return rects.reduce(rects[0]) { $0.union($1) }
    } else {
      return .zero
    }
  }
  
  mutating func remove(_ side: Placement) {
    _ = self.slice(side)
  }

  /**
   This is a mutating function that allows you to "slice" a piece off this rect.  It will return a new rect (the sliced off piece) while also reducing this rect
   by the amount sliced.  You cannot slice off more than what's available or it will end up returning a rect equivalent to this rect and reduce this rect's width/height
   to zero. This function is very useful for layout, as it allows you to take a container and slice of pieces of it to use on the contained views, maintianing the internal calculations
   necessary to maintain what's left/available.
   
   - parameter side: You specify a "sice" (top/left/bottom/right) along with the inset (how much to slice off).
   - returns: A new Rect for the slice.  This rect is modified by reducing it by the sliced off rect.
   */
  mutating func slice(_ side: Placement) -> CGRect {
    switch side {
    case .top(let inset):
      let slice = min(inset, height) // Can't slice off more than what's available
      let rect = CGRect(x: x, y: y, width: width, height: slice)
      origin.y += slice
      size.height -= slice
      return rect
    case .bottom(let inset):
      let slice = min(inset, height) // Can't slice off more than what's available
      let rect = CGRect(x: x, y: maxY - slice, width: width, height: slice)
      size.height -= slice
      return rect
    case .left(let inset):
      let slice = min(inset, width) // Can't slice off more than what's available
      let rect = CGRect(x: x, y: y, width: slice, height: height)
      origin.x += slice
      size.width -= slice
      return rect
    case .right(let inset):
      let slice = min(inset, width) // Can't slice off more than what's available
      let rect = CGRect(x: maxX - slice, y: y, width: slice, height: height)
      size.width -= slice
      return rect
    }
  }
  
}
