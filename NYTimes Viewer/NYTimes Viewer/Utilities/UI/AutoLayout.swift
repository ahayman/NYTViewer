//
//  AutoLayout.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/26/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
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
}

enum ConstraintXPin {
  case leading
  case trailing
  case left
  case right

  func anchor(for view: UIView) -> NSLayoutXAxisAnchor {
    switch self {
    case .leading: return view.leadingAnchor
    case .trailing: return view.trailingAnchor
    case .left: return view.leftAnchor
    case .right: return view.rightAnchor
    }
  }
  
  func anchor(for guide: UILayoutGuide) -> NSLayoutXAxisAnchor {
    switch self {
    case .leading: return guide.leadingAnchor
    case .trailing: return guide.trailingAnchor
    case .left: return guide.leftAnchor
    case .right: return guide.rightAnchor
    }
  }
  
  var opposing: ConstraintXPin {
    switch self {
    case .leading: return .trailing
    case .trailing: return .leading
    case .left: return .right
    case .right: return .left
    }
  }
}

enum ConstraintYPin {
  case top
  case bottom
  
  func anchor(for view: UIView) -> NSLayoutYAxisAnchor {
    switch self {
    case .bottom: return view.bottomAnchor
    case .top: return view.topAnchor
    }
  }
  
  func anchor(for guide: UILayoutGuide) -> NSLayoutYAxisAnchor {
    switch self {
    case .bottom: return guide.bottomAnchor
    case .top: return guide.topAnchor
    }
  }
  
  var opposing: ConstraintYPin {
    switch self {
    case .bottom: return .top
    case .top: return .bottom
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
}



// MARK: Pinning to other Views
extension UIView {
  
  func pin(_ pin: ConstraintXPin, to: ConstraintXPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: to.anchor(for: view), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: view), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: view), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintYPin, to: ConstraintYPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: to.anchor(for: view), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: view), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: view), constant: offset)
    }
  }

  func pin(_ pin: ConstraintXPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: view), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: view), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: view), constant: offset)
    }
  }

  func pin(_ pin: ConstraintYPin, in view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: view), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: view), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: view), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintXPin, nextTo view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: view), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset)
    }
  }

  func pin(_ pin: ConstraintYPin, nextTo view: UIView, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: view), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: view), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintDimension, to: ConstraintDimension? = nil, to view: UIView? = nil, equals: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch equals {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: (to ?? pin).anchor(for: view ?? self), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: (to ?? pin).anchor(for: view ?? self), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: (to ?? pin).anchor(for: view ?? self), constant: offset)
    }
  }
  
}


// MARK: Pinning to Guides
extension UIView {
  
  func pin(_ pin: ConstraintXPin, to: ConstraintXPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: to.anchor(for: guide), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: guide), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: guide), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintYPin, to: ConstraintYPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: to.anchor(for: guide), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: to.anchor(for: guide), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: to.anchor(for: guide), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintXPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: guide), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: guide), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: guide), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintYPin, in guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.anchor(for: guide), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.anchor(for: guide), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.anchor(for: guide), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintXPin, nextTo guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: guide), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset)
    }
  }
  
  func pin(_ pin: ConstraintYPin, nextTo guide: UILayoutGuide, offset: ConstraintEquality = .equal(to: 0)) -> NSLayoutConstraint {
    switch offset {
    case .equal(let offset): return pin.anchor(for: self).constraint(equalTo: pin.opposing.anchor(for: guide), constant: offset)
    case .greaterEqual(let offset): return pin.anchor(for: self).constraint(greaterThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset)
    case .lesserEqual(let offset): return pin.anchor(for: self).constraint(lessThanOrEqualTo: pin.opposing.anchor(for: guide), constant: offset)
    }
  }
  
}
  

extension UIView {
  func usingAutoLayout() -> Self {
    self.translatesAutoresizingMaskIntoConstraints = false
    return self
  }
}
