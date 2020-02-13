//
//  CGSize+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

extension CGSize {
  
  static var max: CGSize {
    return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
  }
  
  init(_ width: CGFloat, _ height: CGFloat) {
    self.init(width: width, height: height)
  }
  
  init(squared: CGFloat) {
    self.init(width: squared, height: squared)
  }
  
  /// Chaining func to modify either the width or heigh and return the new size
  func set(width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
    var size = self
    if let width = width { size.width = width }
    if let height = height { size.height = height }
    return size
  }
  
  func aspectFit(to size: CGSize) -> CGSize {
    var newSize = size
    let wratio = size.width / width
    let hratio = size.height / height
    if wratio > hratio {
      newSize.width = size.height / height * width
    } else {
      newSize.height = size.width / height * width
    }
    
    return newSize
  }
  
  func maxed(to size: CGSize) -> CGSize {
    return CGSize(
      width: Swift.min(width, size.width),
      height: Swift.min(height, size.height))
  }
  
}
