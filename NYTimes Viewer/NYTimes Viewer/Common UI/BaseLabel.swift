//
//  Label.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

extension BaseLabel.Padding {
  init(all: CGFloat) {
    self = BaseLabel.Padding(top: all, leading: all, bottom: all, trailing: all)
  }
}

/**
 A View that can display a label.  While it uses a UILabel underneath, it provide more options for alignment,
 and layout.  As a subclass of View, it also allows you to set borders on it.
 */
class BaseLabel : UIView {
  typealias Padding = NSDirectionalEdgeInsets
  
  enum Alignment {
    case top, center, bottom
  }
  
  // MARK: State Variables
  
  func setPadding(_ padding: Padding) -> Self {
    self.padding = padding
    return self
  }
  var padding = Padding() {
    didSet{ updateConstraints() }
  }
  
  func setTextAlignment(_ textAlignment: NSTextAlignment) -> Self {
    self.textAlignment = textAlignment
    return self
  }
  
  var textAlignment: NSTextAlignment {
    get { return label.textAlignment }
    set { label.textAlignment = newValue }
  }

  func setVertical(_ vertical: Alignment) -> Self {
    self.vertical = vertical
    return self
  }
  var vertical: Alignment = .center {
    didSet { updateConstraints() }
  }
  
  // MARK: Subview Generation
  
  let label: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.translatesAutoresizingMaskIntoConstraints = false
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

  private var labelConstraints: [NSLayoutConstraint] = []
  private func setupContrainst() {
    NSLayoutConstraint.deactivate(labelConstraints)
    
    switch vertical {
    case .top: labelConstraints = [
      label.pin(.top, in: self, offset: .equal(to: padding.bottom)),
      label.pin(.bottom, in: self, offset: .greaterEqual(to: padding.top)),
      label.pin(.leading, in: self, offset: .equal(to: padding.leading)),
      label.pin(.trailing, in: self, offset: .equal(to: padding.trailing))
    ]
    case .center: labelConstraints = [
      label.pin(.top, in: self, offset: .greaterEqual(to: padding.top)),
      label.pin(.bottom, in: self, offset: .greaterEqual(to: padding.bottom)),
      label.pin(.leading, in: self, offset: .equal(to: padding.leading)),
      label.pin(.trailing, in: self, offset: .equal(to: padding.trailing))
    ]
    case .bottom: labelConstraints = [
      label.pin(.top, in: self, offset: .greaterEqual(to: padding.top)),
      label.pin(.bottom, in: self, offset: .equal(to: padding.bottom)),
      label.pin(.leading, in: self, offset: .equal(to: padding.leading)),
      label.pin(.trailing, in: self, offset: .equal(to: padding.trailing))
    ]
    }

    NSLayoutConstraint.activate(labelConstraints)
  }
}
