//
//  String+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/12/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

extension Substring {
  var string: String {
    return String(self)
  }
}

typealias Regex = NSRegularExpression

extension String {
  
  var intValue: Int? {
    return Int(self)
  }
  
  var doubleValue: Double? {
    return Double(self)
  }
  
  var floatValue: Float? {
    return Float(self)
  }
  
  func toRegex(options: NSRegularExpression.Options = []) -> Regex? {
    return try? NSRegularExpression(pattern: self, options: options)
  }
  
  var regex: Regex? {
    return toRegex()
  }
  
  func chunked(size: UInt) -> [String] {
    let s = Int(size)
    var chunks = [String]()
    var start = startIndex
    var end = index(start, offsetBy: s, limitedBy: endIndex) ?? endIndex
    repeat {
      chunks.append(self[start..<end].string)
      start = end
      end = index(start, offsetBy: s, limitedBy: endIndex) ?? endIndex
    } while (start != endIndex)
    return chunks
  }
  
  func replace(_ term: String, with replace: String) -> String {
    return self.replacingOccurrences(of: term, with: replace)
  }
  
  func rangeOf(_ nsRange: NSRange) -> Range<String.Index> {
    let start = index(startIndex, offsetBy: nsRange.location)
    let end = index(start, offsetBy: nsRange.length)
    return start..<end
  }
  
  func replace(_ regex: Regex, with replace: String) -> String {
    var str = self
    regex.matches(in: self, options: [], range: NSRange(location: 0, length: count))
      .map { $0.range }
      .sorted(.descending) { $0.location }
      .forEach { str.replaceSubrange(str.rangeOf($0), with: replace) }
    return str
  }
  
  func deleteAll(_ term: String) -> String {
    return replace(term, with: "")
  }
  
  func deleteAll(_ regex: Regex) -> String {
    return replace(regex, with: "")
  }
  
  func matches(_ regex: Regex) -> Bool {
    return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
  }

  func replaceCharacters(inSet set: Set<Character>, with repl: String) -> String {
    return self.reduce("") { r, n in set.contains(n) ? r + repl : r + String(n) }
  }
  
  func deleteCharacters(inSet set: Set<Character>) -> String {
    return replaceCharacters(inSet: set, with: "")
  }
}

extension StringProtocol where Self: RangeReplaceableCollection {
  
  func subSequence(_ value: NSRange) -> Self.SubSequence {
    return self.subSequence(value.lowerBound..<value.upperBound)
  }
  
  func subSequence(_ value: CountableClosedRange<Int>) -> Self.SubSequence {
      return self[index(at: value.lowerBound)...index(at: value.upperBound)]
  }
  
  func subSequence(_ value: CountableRange<Int>) -> Self.SubSequence {
      return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
  }
  
  subscript(value: PartialRangeUpTo<Int>) -> Self.SubSequence {
    get {
      if (value.upperBound > 0) {
        return self[..<index(at: value.upperBound)]
      } else {
        return self[..<index(endIndex, offsetBy: value.upperBound)]
      }
    }
  }
  
  subscript(value: PartialRangeThrough<Int>) -> Self.SubSequence {
    get {
      if (value.upperBound > 0) {
        return self[...index(at: value.upperBound)]
      } else {
        return self[...index(endIndex, offsetBy: value.upperBound)]
      }
    }
  }
  
  subscript(value: PartialRangeFrom<Int>) -> Self.SubSequence {
    get {
      if value.lowerBound >= 0 {
        return self[index(at: value.lowerBound)...]
      } else {
        return self[index(endIndex, offsetBy: value.lowerBound)...]
      }
    }
  }
  
  func index(at offset: Int) -> String.Index {
    return index(startIndex, offsetBy: offset)
  }
}
