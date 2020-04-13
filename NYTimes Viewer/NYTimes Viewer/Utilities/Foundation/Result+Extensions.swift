import Foundation

extension Result {
  
  /**
   An easy way to retrieve the value on success without resorting to try.
   - returns: Success value on `.success`, `nil` otherwise.
   */
  var value: Success? {
    switch self {
    case .failure: return nil
    case .success(let value): return value
    }
  }
  
  /**
   An easy way to retrieve a failure if there is one.
   - returns: Error on `.failure`, `nil` otherwise
   */
  var error: Failure? {
    switch self {
    case .failure(let error): return error
    case .success: return nil
    }
  }
}
