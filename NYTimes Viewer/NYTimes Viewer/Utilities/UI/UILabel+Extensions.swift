//
//  UILabel+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

extension UILabel {
  
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

}
