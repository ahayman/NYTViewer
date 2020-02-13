//
//  View.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

enum Length {
  case full
  case absolute(CGFloat)
  case proportional(CGFloat)
}

enum Border {
  case top(width: CGFloat, color: UIColor, length: Length)
  case bottom(width: CGFloat, color: UIColor, length: Length)
  case left(width: CGFloat, color: UIColor, length: Length)
  case right(width: CGFloat, color: UIColor, length: Length)
}

/**
 This is a Baseclass that adds additional options to a standard UIView
 Specifically, it allows you to specify custom borders along the edges.
 Borders are drawn inside the View and you can specify multiple borders along the same edge,
 which will be layered in the order to provide them.
 */
class BaseView : UIView {
  
  
  /// Set borders to be drawn.  All borders will be drawn, even if they overlap or are drawn over each other.
  @discardableResult func set(borders: Border...) -> Self {
    self.borders = borders
    return self
  }
  
  var borders: [Border] = [] {
    didSet { self.setNeedsDisplay() }
  }
  
  override func draw(_ rect: CGRect) {
    for border in borders {
      switch border {
      case let .top(width, color, length):
        var rect = CGRect(h: width)
        switch length {
        case .full: rect.size.width = self.bounds.width
        case .absolute(let length):
          rect.size.width = length
          rect.origin.x = bounds.midX - rect.width / 2
        case .proportional(let prop):
          rect.size.width = bounds.width * prop
          rect.origin.x = bounds.midX - rect.width / 2
        }
        color.setFill()
        UIBezierPath(rect: rect).fill()
      case let .bottom(width, color, length):
        var rect = CGRect(y: bounds.maxY - width, h: width)
        switch length {
        case .full: rect.size.width = self.bounds.width
        case .absolute(let length):
          rect.size.width = length
          rect.origin.x = bounds.midX - rect.width / 2
        case .proportional(let prop):
          rect.size.width = bounds.width * prop
          rect.origin.x = bounds.midX - rect.width / 2
        }
        color.setFill()
        UIBezierPath(rect: rect).fill()
      case let .left(width, color, length):
        var rect = CGRect(w: width)
        switch length {
        case .full: rect.size.height = bounds.height
        case .absolute(let length):
          rect.size.height = length
          rect.origin.y = bounds.midY - rect.height / 2
        case .proportional(let prop):
          rect.size.height = bounds.height * prop
          rect.origin.y = bounds.midY - rect.height / 2
        }
        color.setFill()
        UIBezierPath(rect: rect).fill()
      case let .right(width, color, length):
        var rect = CGRect(x: bounds.maxX - width, w: width)
        switch length {
        case .full: rect.size.height = bounds.height
        case .absolute(let length):
          rect.size.height = length
          rect.origin.y = bounds.midY - rect.height / 2
        case .proportional(let prop):
          rect.size.height = bounds.height * prop
          rect.origin.y = bounds.midY - rect.height / 2
        }
        color.setFill()
        UIBezierPath(rect: rect).fill()
      }
    }
  }
  
}

import SwiftUI
struct BaseViewPreview: PreviewProvider, UIViewRepresentable {
  
  static var previews: some View { BaseViewPreview() }
  
  func makeUIView(context: Context) -> UIView {
    let view = BaseView(frame: .zero)
    view.cornerRadius = 5.0
    view.backgroundColor = .brown
    return view
  }
  
  func updateUIView(_ view: UIView, context: Context) { }
}
