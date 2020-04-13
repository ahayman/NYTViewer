import Foundation

extension Date {
  
  /// Same as `timeIntervalSinceReferenceDate` because brevity matters
  static var timeInterval: TimeInterval {
    return Date.timeIntervalSinceReferenceDate
  }
  
  /// Same as `timeIntervalSinceReferenceDate` because brevity matters
  var timeInterval: TimeInterval {
    return self.timeIntervalSinceReferenceDate
  }
  
  /**
   This will calculate the *absolute distance* between the two dates.
   */
  func distance(to: Date) -> TimeInterval {
    return abs(self.timeInterval - to.timeInterval)
  }
}
