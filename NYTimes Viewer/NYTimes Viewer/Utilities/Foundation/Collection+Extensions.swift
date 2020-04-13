import Foundation

enum SortDirection {
  case ascending
  case descending
  
  var flipped: SortDirection { switch self {
  case .ascending: return .descending
  case .descending: return .ascending
  }}
}

extension Sequence where Element: Numeric {
  func sum() -> Element {
    return reduce(0) { $0 + $1 }
  }
}

/**
 Convenience operator to allow appending a single item to an array without wrapping that item first into another array.
 */
@discardableResult func += <T>(lhs: inout [T], rhs: T) -> [T] {
  lhs.append(rhs)
  return lhs
}

extension Array {
  
  func sorted<T: Comparable>(_ direction: SortDirection = .ascending, on: (Element) -> T) -> [Element] {
    return sorted{ l, r -> Bool in
      switch direction {
      case .ascending: return on(l) < on(r)
      case .descending: return on(r) < on(l)
      }
    }
  }
  
  func get(_ at: Index) -> Element? {
    guard at >= startIndex && at < endIndex else { return nil }
    return self[at]
  }

  func replacing(_ index: Int, with object: Element) -> [Element] {
    var array = self
    array[index] = object
    return array
  }
  
  func modifying(_ index: Int, modifyer: (inout Element) -> Void) -> [Element] {
    var array = self
    var object = array[index]
    modifyer(&object)
    array[index] = object
    return array
  }
  
  mutating func filtered(_ isIncluded: (Element) -> Bool) {
    self = self.filter(isIncluded)
  }
  
  func zip<U>(_ array: [U]) -> [(Element, U)] {
    return (0..<(Swift.min(count, array.count))).map { (self[$0], array[$0]) }
  }
  
  func index(where isMatch: (Element) -> Bool) -> Int? {
    for (idx, e) in self.enumerated() {
      if isMatch(e) { return idx }
    }
    return nil
  }

}

extension Collection {
  var isNotEmpty: Bool { return !isEmpty }
}

extension Sequence {
  func forEachIndexed(op: (Int, Element) -> Void) {
    var index = 0
    for element in self {
      op(index, element)
      index += 1
    }
  }
  
  func mapIndexed<T>(op: (Int, Element) -> T) -> [T] {
    var mapped = [T]()
    for (idx, elem) in self.enumerated() {
      mapped.append(op(idx, elem))
    }
    return mapped
  }
}

extension Range where Bound == Int {
  func offset(by offset: Int) -> Range {
    return (lowerBound + offset)..<(upperBound + offset)
  }
}

extension ClosedRange where Bound == Int {
  func offset(by offset: Int) -> ClosedRange {
    return (lowerBound + offset)...(upperBound + offset)
  }
}

extension Dictionary {
  func removing(keys: [Key]) -> Dictionary {
    var dict = self
    keys.forEach{ dict[$0] = nil }
    return dict
  }
  
  func keeping(keys: [Key]) -> Dictionary {
    var dict = [Key:Value]()
    self.keys.forEach{
      if !keys.contains($0) { dict[$0] = self[$0] }
    }
    return dict
  }
  
}

extension Collection where Index == Int {
  
  func chunked(_ size: Int) -> [Self.SubSequence] {
    guard isNotEmpty else { return [] }
    var chunks = [Self.SubSequence]()
    var start = self.startIndex
    var end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
    repeat {
      let chunk = self[start..<end]
      chunks.append(chunk)
      start = end
      end = index(start, offsetBy: size, limitedBy: count) ?? endIndex
    } while (start < count)
    
    return chunks
  }
  
}
