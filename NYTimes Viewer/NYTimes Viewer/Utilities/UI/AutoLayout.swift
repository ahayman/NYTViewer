//
//  AutoLayout.swift
//  UITests
//
//  Created by Aaron Hayman on 4/13/20.
//  Copyright © 2020 Aaron Hayman. All rights reserved.
//

import UIKit

/**
 A simple property wrapper that preps the view to use AutoLayout.
 This avoid us having to constantly set `translatesAutoresizingMaskIntoConstraints` on init.
 */
@propertyWrapper
public struct AutoLayout<T: UIView> {
  public var wrappedValue: T {
    didSet { setAutoLayout() }
  }
  
  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
    setAutoLayout()
  }
  
  func setAutoLayout() {
    wrappedValue.translatesAutoresizingMaskIntoConstraints = false
  }
}

enum ConstraintEquality : ExpressibleByFloatLiteral {
  typealias FloatLiteralType = Double
  
  case equal(to: CGFloat)
  case greaterEqual(to: CGFloat)
  case lesserEqual(to: CGFloat)
  
  init(floatLiteral value: Double) {
    self = .equal(to: CGFloat(value))
  }
  
  var value: CGFloat { switch self {
  case let .equal(to): return to
  case let .greaterEqual(to): return to
  case let .lesserEqual(to): return to
    }}
  
  func valueFor(_ pin: ConstraintXPin) -> CGFloat { switch pin {
  case .leading, .left, .centerX: return self.value
  case .trailing, .right: return self.value * -1
    }}
  
  func valueFor(_ pin: ConstraintYPin) -> CGFloat { switch pin {
  case .top, .centerY: return self.value
  case .bottom: return self.value * -1
    }}
  
}

enum ConstraintXPin {
  case leading
  case trailing
  case left
  case right
  case centerX
  
  func anchor(for view: UIView) -> NSLayoutXAxisAnchor {
    switch self {
    case .leading: return view.leadingAnchor
    case .trailing: return view.trailingAnchor
    case .left: return view.leftAnchor
    case .right: return view.rightAnchor
    case .centerX: return view.centerXAnchor
    }
  }
  
  func anchor(for guide: UILayoutGuide) -> NSLayoutXAxisAnchor {
    switch self {
    case .leading: return guide.leadingAnchor
    case .trailing: return guide.trailingAnchor
    case .left: return guide.leftAnchor
    case .right: return guide.rightAnchor
    case .centerX: return guide.centerXAnchor
    }
  }
  
  var opposing: ConstraintXPin {
    switch self {
    case .leading: return .trailing
    case .trailing: return .leading
    case .left: return .right
    case .right: return .left
    case .centerX: return .centerX
    }
  }
}

enum ConstraintYPin {
  case top
  case bottom
  case centerY
  
  func anchor(for view: UIView) -> NSLayoutYAxisAnchor {
    switch self {
    case .bottom: return view.bottomAnchor
    case .top: return view.topAnchor
    case .centerY: return view.centerYAnchor
    }
  }
  
  func anchor(for guide: UILayoutGuide) -> NSLayoutYAxisAnchor {
    switch self {
    case .bottom: return guide.bottomAnchor
    case .top: return guide.topAnchor
    case .centerY: return guide.centerYAnchor
    }
  }
  
  var opposing: ConstraintYPin {
    switch self {
    case .bottom: return .top
    case .top: return .bottom
    case .centerY: return .centerY
    }
  }
}

enum ConstraintDimension {
  case height
  case width
  
  func anchor(for view: UIView) -> NSLayoutDimension {
    switch self {
    case .height: return view.heightAnchor
    case .width: return view.widthAnchor
    }
  }
  
  func anchor(for guide: UILayoutGuide) -> NSLayoutDimension {
    switch self {
    case .height: return guide.heightAnchor
    case .width: return guide.widthAnchor
    }
  }
}

extension UILayoutPriority {
  static var veryLow: UILayoutPriority {
    return UILayoutPriority(rawValue: 1)
  }
  static var low: UILayoutPriority {
    return UILayoutPriority(rawValue: 150)
  }
  static var medium: UILayoutPriority {
    return UILayoutPriority(rawValue: 500)
  }
  static var high: UILayoutPriority {
    return UILayoutPriority(rawValue: 850)
  }
  static var veryHigh: UILayoutPriority {
    return UILayoutPriority(rawValue: 999)
  }
  
}

extension NSLayoutConstraint {
  func with(priority: UILayoutPriority) -> Self {
    self.priority = priority
    return self
  }
}


// MARK: Pinning to other Views
extension UIView {
  
  func pin(_ pin: ConstraintXPin, to: ConstraintXPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: to.anchor(for: view), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: view), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: view), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintYPin, to: ConstraintYPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: to.anchor(for: view), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: view), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: view), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintXPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: view), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: view), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: view), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintYPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: view), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: view), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: view), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintXPin, nextTo view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: view), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintYPin, nextTo view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: view), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintDimension, to: ConstraintDimension? = nil, to view: UIView? = nil, equals: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    if let view = view {
      switch equals {
      case .equal: return pin.anchor(for: self).constraint(equalTo: (to ?? pin).anchor(for: view), constant: equals.value)
      case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: (to ?? pin).anchor(for: view), constant: equals.value)
      case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: (to ?? pin).anchor(for: view), constant: equals.value)
      }
    } else if let to = to, pin != to {
      return pin.anchor(for: self).constraint(equalTo: to.anchor(for: self))
    } else {
      switch equals {
      case .equal: return pin.anchor(for: self).constraint(equalToConstant:  equals.value)
      case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualToConstant: equals.value)
      case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualToConstant: equals.value)
      }
    }
  }
  
}


// MARK: Pinning to Guides
extension UIView {
  
  func pin(_ pin: ConstraintXPin, to: ConstraintXPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: to.anchor(for: guide), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: guide), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: guide), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintYPin, to: ConstraintYPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: to.anchor(for: guide), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: guide), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: guide), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintXPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: guide), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: guide), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: guide), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintYPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: guide), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: guide), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: guide), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintXPin, nextTo guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: guide), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintYPin, nextTo guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal: return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: guide), constant: offset.valueFor(pin))
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset.valueFor(pin))
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset.valueFor(pin))
    }
  }
  
  func pin(_ pin: ConstraintDimension, to: ConstraintDimension? = nil, to guide: UILayoutGuide, equals: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch equals {
    case .equal: return pin.anchor(for: self).constraint(equalTo: (to ?? pin).anchor(for: guide), constant: equals.value)
    case .greaterEqual: return pin.anchor(for: self).constraint(greaterThanOrEqualTo: (to ?? pin).anchor(for: guide), constant: equals.value)
    case .lesserEqual: return pin.anchor(for: self).constraint(lessThanOrEqualTo: (to ?? pin).anchor(for: guide), constant: equals.value)
    }
  }
  
}


extension UIView {
  func usingAutoLayout() -> Self {
    self.translatesAutoresizingMaskIntoConstraints = false
    return self
  }
  func useAutoLayout() {
    self.translatesAutoresizingMaskIntoConstraints = false
  }
}
