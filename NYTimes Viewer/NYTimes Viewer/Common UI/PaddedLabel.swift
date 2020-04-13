//
//  PaddedLabel.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 4/13/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
  
  var padding: NSDirectionalEdgeInsets = .zero
  
  private var inset: UIEdgeInsets {
    switch self.effectiveUserInterfaceLayoutDirection {
    case .leftToRight: return UIEdgeInsets(top: padding.top, left: padding.leading, bottom: padding.bottom, right: padding.trailing)
    case .rightToLeft: return UIEdgeInsets(top: padding.top, left: padding.trailing, bottom: padding.bottom, right: padding.leading)
    @unknown default: return UIEdgeInsets(top: padding.top, left: padding.leading, bottom: padding.bottom, right: padding.trailing)
    }
  }
  
  @discardableResult func setPadding(leading: CGFloat? = nil, trailing: CGFloat? = nil, top: CGFloat? = nil, bottom: CGFloat? = nil) -> Self {
    padding = NSDirectionalEdgeInsets(top: top ?? padding.top, leading: leading ?? padding.leading, bottom: bottom ?? padding.bottom, trailing: trailing ?? padding.trailing)
    setNeedsDisplay()
    setNeedsLayout()
    return self
  }
  
  @discardableResult func setPadding(horizontal: CGFloat? = nil, vertical: CGFloat? = nil) -> Self {
    padding = NSDirectionalEdgeInsets(top: vertical ?? padding.top, leading: horizontal ?? padding.leading, bottom: vertical ?? padding.bottom, trailing: horizontal ?? padding.trailing)
    setNeedsDisplay()
    setNeedsLayout()
    return self
  }

  @discardableResult func setPadding(all: CGFloat) -> Self {
    padding = NSDirectionalEdgeInsets(top: all, leading: all, bottom: all, trailing: all)
    setNeedsDisplay()
    setNeedsLayout()
    return self
  }
  
  override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    size.width += (padding.leading + padding.trailing)
    size.height += (padding.top + padding.bottom)
    return size
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var testSize = size
    testSize.width -= (padding.leading + padding.trailing)
    testSize.height -= (padding.top + padding.bottom)
    testSize = super.sizeThatFits(testSize)
    testSize.width += (padding.leading + padding.trailing)
    testSize.height += (padding.top + padding.bottom)
    return testSize
  }
  
  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: inset))
  }
}
