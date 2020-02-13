//
//  CGPoint+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

enum Shift {
  case left(CGFloat), right(CGFloat), up(CGFloat), down(CGFloat)
}

extension CGPoint {
  
  /// Chaining function, because they're awesome
  func set(x: CGFloat? = nil, y: CGFloat? = nil) -> CGPoint {
    var point = self
    if let x = x { point.x = x }
    if let y = y { point.y = y }
    return point
  }
  
  func shifted(_ direction: Shift) -> CGPoint {
    switch direction {
    case let .left(offset): return CGPoint(x: x - offset, y: y)
    case let .right(offset): return CGPoint(x: x + offset, y: y)
    case let .up(offset): return CGPoint(x: x, y: y - offset)
    case let .down(offset): return CGPoint(x: x, y: y + offset)
    }
  }
  
}
