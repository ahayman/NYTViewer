//
//  Operators.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/11/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

/**
 This is mostly a convenience operator that allows you to take an optional value and pass it into a transform.
 At it's core, it allows you to avoid common code like:
 
 ```
 if let x = y {
 self.z = self.mapToZ(y)
 } else {
 self.z = nil
 }
 ```
 
 into a single line:
 ```
 self.z = x ?>> { self.mapToZ($0) }
 ```
 */
infix operator ?>> : AssignmentPrecedence
@discardableResult public func ?>><T,U>(lhs: T?, rhs: (T) throws -> U?) rethrows -> U? {
  guard let val = lhs else { return nil }
  return try rhs(val)
}

/**
 This is an assignment operator that allows you to take an item, configure it in a closure, and then return the configured object
 as an assignment.  It essentially replaces the generic closure pattern that returns an object (`() -> T`) by separating out the creation and return
 from the configuration. A great example is iVars:
 
 ```
 let someIvar: Variable = {
   let var = Variable()
   var.configA = A
   var.configB = B
   return var
 }()
 ```
 
 This is a common usage pattern.  However, it's a bit verbose and requires two extra lines (creation and return).  Using the `<<` we can shorten it considerably:
 
 ```
 let someIvar = Variable() << {
   $0.configA = A
   $0.configB = B
 }
 ```
 
 Note: You can also use this purely for configuration, without assignment, but it's generally intended for assignment.
 */
infix operator << : AssignmentPrecedence
@discardableResult public func << <T>(lhs: T, rhs: (T) -> Void) -> T {
  rhs(lhs)
  return lhs
}
@discardableResult public func << <T>(lhs: (T) -> Void, rhs: T) -> T {
  lhs(rhs)
  return rhs
}

infix operator ?> : AssignmentPrecedence
@discardableResult public func ?> <T>(lhs: T?, rhs: @autoclosure () -> T) -> T {
  if let t = lhs { return t }
  return rhs()
}

infix operator >> : AssignmentPrecedence
public func >><T>(lhs: T, rhs: (T) -> Void) {
  rhs(lhs)
}

/**
 Takes a right-hand value and assigns it to the left-hand value _only if_ the right-hand value is non-nil.
 */
infix operator =? : AssignmentPrecedence
public func =?<T>(lhs: inout T?, rhs: T?) {
  if let val = rhs {
    lhs = val
  }
}

public func =?<T>(lhs: inout T, rhs: T?) {
  if let val = rhs {
    lhs = val
  }
}

