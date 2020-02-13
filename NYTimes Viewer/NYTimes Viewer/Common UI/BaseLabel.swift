//
//  Label.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit
/**
 A View that can display a label.  While it uses a UILabel underneath, it provide more options for alignment,
 and layout.  As a subclass of View, it also allows you to set borders on it.
 */
class BaseLabel : BaseView {
  
  // MARK: State Variables
  
  func setPadding(_ padding: UIEdgeInsets) -> Self {
    self.padding = padding
    return self
  }
  var padding = Insets() {
    didSet{ setNeedsLayout() }
  }
  
  func setTextAlignment(_ textAlignment: NSTextAlignment) -> Self {
    self.textAlignment = textAlignment
    return self
  }
  
  var textAlignment: NSTextAlignment {
    get { return label.textAlignment }
    set { label.textAlignment = newValue }
  }
  
  func setHorizontal(_ horizontal: Alignment) -> Self {
    self.horizontal = horizontal
    return self
  }
  
  var horizontal: Alignment = .center {
    didSet { setNeedsLayout() }
  }
  
  func setVertical(_ vertical: Alignment) -> Self {
    self.vertical = vertical
    return self
  }
  var vertical: Alignment = .center {
    didSet { setNeedsLayout() }
  }
  
  // MARK: Subview Generation
  
  let label: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    return label
  }()
  
  // MARK: Pass-throughs
  
  @discardableResult func setText(_ text: String?) -> Self {
    self.text = text
    return self
  }
  
  var text: String? {
    get { return label.text }
    set {
      label.text = newValue
      setNeedsLayout()
    }
  }
  
  func setFont(_ font: UIFont) -> Self {
    self.font = font
    return self
  }
  
  var font: UIFont {
    get { return label.font }
    set {
      label.font = newValue
      setNeedsLayout()
    }
  }
  
  func setTextColor(_ textColor: UIColor) -> Self {
    self.textColor = textColor
    return self
  }
  
  var textColor: UIColor {
    get { return label.textColor }
    set { label.textColor = newValue }
  }
  
  func setNumberOfLines(_ numberOfLines: Int) -> Self {
    self.numberOfLines = numberOfLines
    return self
  }
  
  var numberOfLines: Int {
    get { return label.numberOfLines }
    set {
      label.numberOfLines = newValue
      setNeedsLayout()
    }
  }
  
  func setLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
    self.lineBreakMode = lineBreakMode
    return self
  }
  
  var lineBreakMode: NSLineBreakMode {
    get { return label.lineBreakMode }
    set {
      label.lineBreakMode = newValue
      setNeedsLayout()
    }
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var s = label.sizeThatFits(size)
    s.width += max(horizontal.offset.absolute, padding.horizontal)
    s.height += max(vertical.offset.absolute, padding.vertical)
    return s
  }
  
  override func sizeToFit() {
    frame = frame.set(size: sizeThatFits(bounds.size))
    setNeedsLayout()
  }
  
  func sizeToFit(text: String, padding: CGFloat = 0) {
    let orig = self.text
    self.text = text
    sizeToFit()
    width += padding * 2
    height += padding * 2
    self.text = orig
  }
  
  func sizeThatFits(_ size: CGSize, for text: String, padding: CGFloat = 0) -> CGSize {
    let orig = self.text
    self.text = text
    var newSize = sizeThatFits(size)
    self.text = orig
    newSize.width += padding * 2
    newSize.height += padding * 2
    return newSize
  }
  
  // MARK: Init & Layout
  
  init(_ text: String? = nil) {
    super.init(frame: CGRect())
    backgroundColor = .clear
    label.text = text
    self.clipsToBounds = true
    addSubview(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    label.frame = CGRect(size: label.sizeThatFits(bounds.size))
      .adjust(.height) { min($0.height, bounds.height) }
      .adjust(.width) { min($0.width, bounds.width) }
      .align(to: bounds, vertical: vertical, horizontal: horizontal)
  }
  
}
