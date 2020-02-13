//
//  UIView+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

extension Sequence where Element == UIView {
  @discardableResult func sizeToFit() -> Self {
    for view in self { view.sizeToFit() }
    return self
  }
  
  @discardableResult func removeFromSuperview() -> Self {
    for view in self { view.removeFromSuperview() }
    return self
  }
  
  @discardableResult func show() -> Self {
    for view in self { view.isHidden = false }
    return self
  }
  
  @discardableResult func hide() -> Self {
    for view in self { view.isHidden = true }
    return self
  }
  
  @discardableResult func set(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil, maxX: CGFloat? = nil, maxY: CGFloat? = nil) -> Self {
    for view in self { view.set(x: x, y: y, width: width, height: height, maxX: maxX, maxY: maxY) }
    return self
  }
  
  @discardableResult func set(origin: CGPoint? = nil, size: CGSize? = nil) -> Self {
    for view in self { view.set(origin: origin, size: size) }
    return self
  }
  
  @discardableResult func set(frame: CGRect) -> Self {
    for view in self { view.frame = frame }
    return self
  }
  
  @discardableResult func set(backgroundColor: UIColor) -> Self {
    for view in self { view.backgroundColor = backgroundColor }
    return self
  }
  
  @discardableResult func adjust(_ dimension: RectDimension, adjuster: (CGRect) -> CGFloat) -> Self {
    for view in self { view.frame = view.frame.adjust(dimension, adjuster: adjuster) }
    return self
  }
  
  /// Inset the view frame on all edges
  @discardableResult func inset(all inset: CGFloat) -> Self {
    for view in self {
      view.frame = view.frame.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
    }
    return self
  }
  
  /// Inset the view frame on insets provided
  @discardableResult func inset(by insets: UIEdgeInsets) -> Self {
    for view in self { view.frame = view.frame.inset(by: insets) }
    return self
  }
  
  /// Inset the view frame by one or more sides
  @discardableResult func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
    for view in self { view.frame = view.frame.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)) }
    return self
  }
  
  /// position the View in another rect
  @discardableResult func align(to ref: CGRect, vertical: Alignment? = nil, horizontal: Alignment? = nil) -> Self {
    for view in self { view.frame = view.frame.align(to: ref, vertical: vertical, horizontal: horizontal) }
    return self
  }
  
  @discardableResult func setHidden(_ hidden: Bool) -> Self {
    for view in self { view.isHidden = hidden }
    return self
  }
  
  @discardableResult func resign() -> Self {
    for view in self { view.resignFirstResponder() }
    return self
  }
}

extension UIView {
  
  @discardableResult func set(cornerRadius: CGFloat) -> Self {
    self.cornerRadius = cornerRadius
    return self
  }
  
  func resign() {
    self.resignFirstResponder()
  }
  
  /// Sets the corner radius of the underlying layer.  We also mark this as IBInspectible so the adjustment can be made in all IB views.
  @IBInspectable var cornerRadius: CGFloat {
    get { return layer.cornerRadius }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  /// Sets the border width of the underlying layer.  We also mark this as IBInspectible so the adjustment can be made in all IB views.
  @IBInspectable var borderWidth: CGFloat {
    get { return layer.borderWidth }
    set { layer.borderWidth = newValue }
  }
  
  /// Sets the border color of the underlying layer.  We also mark this as IBInspectible so the adjustment can be made in all IB views.
  @IBInspectable var borderColor: UIColor? {
    get { return layer.borderColor ?>> { UIColor(cgColor: $0) }}
    set { layer.borderColor = newValue?.cgColor }
  }
  
  @discardableResult func setHidden(_ hidden: Bool = true) -> Self {
    self.isHidden = hidden
    return self
  }
  
  @discardableResult func set(alpha: CGFloat) -> Self {
    self.alpha = alpha
    return self
  }
  
  @discardableResult func set(interactable: Bool) -> Self {
    self.isUserInteractionEnabled = interactable
    return self
  }
  
  func addSubviews(_ subviews: UIView...) {
    self.addSubviews(subviews)
  }
  
  /// Add multiple subviews at one time
  func addSubviews(_ subviews: [UIView]) {
    for subView in subviews {
      self.addSubview(subView)
    }
  }
  
  var safeBounds: CGRect {
    return bounds.inset(by: safeAreaInsets)
  }
  
}

// MARK: Frame Placement
extension UIView {
  
  var origin: CGPoint {
    get { return self.frame.origin }
    set { set(origin: newValue) }
  }
  var size: CGSize {
    get { return self.frame.size }
    set { set(size: newValue) }
  }
  var height: CGFloat {
    get { return self.frame.size.height }
    set { set(height: newValue) }
  }
  var width: CGFloat {
    get { return self.frame.size.width }
    set { set(width: newValue) }
  }
  var x: CGFloat {
    get { return self.frame.origin.x }
    set { set(x: newValue) }
  }
  var y: CGFloat {
    get { return self.frame.origin.y }
    set { set(y: newValue) }
  }
  var maxX: CGFloat {
    get { return self.frame.maxX }
    set { set(maxX: newValue) }
  }
  var maxY: CGFloat {
    get { return self.frame.maxY }
    set { set(maxY: newValue) }
  }
  
  /// Chaining Operator that allows you to set the view frame by setting one or more parameters.  Note: maxX & maxY parameters are applied last and will override width/height
  @discardableResult func set(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil, maxX: CGFloat? = nil, maxY: CGFloat? = nil) -> Self {
    self.frame = self.frame.set(x: x, y: y, width: width, height: height, maxX: maxX, maxY: maxY)
    return self
  }
  
  /// Chaining Operator that allows you to set the frame
  @discardableResult func set(frame: CGRect) -> Self {
    self.frame = frame
    return self
  }

  /// Chaining Operator that allows you to set the frame by setting either the origin or the size
  @discardableResult func set(origin: CGPoint? = nil, size: CGSize? = nil) -> Self {
    self.frame = self.frame.set(origin: origin, size: size)
    return self
  }
  
  /// Allows you to adjust a specific dimension of the view frame by passing that dimension into the adjuster and setting the views dimension to the result.
  @discardableResult func adjust(_ dimension: RectDimension, adjuster: (CGRect) -> CGFloat) -> Self {
    self.frame = self.frame.adjust(dimension, adjuster: adjuster)
    return self
  }
  
  /// Inset the view frame on all edges
  @discardableResult func inset(all inset: CGFloat) -> Self {
    self.frame = self.frame.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
    return self
  }
  
  /// Inset the view frame on insets provided
  @discardableResult func inset(by insets: UIEdgeInsets) -> Self {
    self.frame = self.frame.inset(by: insets)
    return self
  }
  
  /// Inset the view frame by one or more sides
  @discardableResult func inset(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
    self.frame = self.frame.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    return self
  }
  
  /// position the View in another rect
  @discardableResult func align(to ref: CGRect, vertical: Alignment? = nil, horizontal: Alignment? = nil) -> Self {
    self.frame = self.frame.align(to: ref, vertical: vertical, horizontal: horizontal)
    return self
  }
  
  /**
   This will place the view next to the provided rect on the placement side specified. The value of the placement represents the margin
   between this view frame and the provided rect.
   If `align` is provided, the rect will be aligned to that rect on the opposite axis with which it was placed. So top/bottom placements allow for horizontal alignment
   and left/right placements allow for vertical alignment.  So, for example, if you place the frame at the `top` of the reference rect and align = '.center',
   the view will be place above the provided rect and centered horizontally on that rect.
   This will not resize the view in any fashion.  It only affects placement.
   */
  @discardableResult func place(nextTo ref: CGRect, _ placement: Placement, align: Alignment? = nil) -> Self {
    self.frame = self.frame.place(nextTo: ref, placement, align: align)
    return self
  }
  
  /**
   Positions the view frame positioned according to the the references offsets from a reference Rect.
   Note: If top & bottom or left & right are both set, then the height & width will be altered to fit the view.
   */
  @discardableResult func position(in ref: CGRect, top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) -> Self {
    self.frame = self.frame.position(in: ref, top: top, bottom: bottom, left: left, right: right)
    return self
  }
  
  /**
   This will distribute an array of views in the direction provided, distributed with an equal margin between them.
   This uses the `distribute(... rects:)` function underneath.
   If `sized` is provided, all of the views will be re-sized to the provided size.
   Both `align` and `spaceAround` have the same effect as they do when distributing rects: `align` will align on the opposing axis and
   `spaceAround` will add margins around the the first/last views.
   */
  @discardableResult func distributeViews(_ views: [UIView], direction: Direction, sized: CGSize? = nil, align: Alignment? = nil, spaceAround: Bool = false) -> Self {
    self.bounds.distributeViews(views, direction: direction, sized: sized, align: align, spaceAround: spaceAround)
    return self
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
   - Returns: A array of new rects that have been laid out.
   */
  @discardableResult func layoutViews(_ views: [UIView], direction: Direction, margin: CGFloat, sized: CGSize? = nil, align: Alignment? = nil, justify: Alignment = .start) -> Self {
    self.bounds.layoutViews(views, direction: direction, margin: margin, sized: sized, align: align, justify: justify)
    return self
  }
  
}
