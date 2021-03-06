import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
  
  /**
   An easier way to sink a result.
   No idea why Combine forces you into two separate closures instead of returning a Result type.
   */
  public func sink(result: @escaping (Result<Self.Output, Self.Failure>) -> Void) -> AnyCancellable {
    return self.sink(
      receiveCompletion: { (completion: Subscribers.Completion<Self.Failure>) in
        switch completion {
        case .finished: break
        case .failure(let error): result(.failure(error))
        }
      }, receiveValue: { (value: Self.Output) in
        result(.success(value))
      })
  }
  
  /**
   Sink the value only; ignores errors.
   */
  public func sink(value result: @escaping (Self.Output) -> Void) -> AnyCancellable {
    return self.sink(
      receiveCompletion: { (completion: Subscribers.Completion<Self.Failure>) in },
      receiveValue: { (value: Self.Output) in
        result(value)
    })
  }
  
  /**
   Returns the last value.
   Note: This will only work if the value is cached _and_ the publisher calls a sink
   synchronously. (Published values do this).
   */
  public var lastValue: Self.Output? {
    var value: Output? = nil
    let _ = sink { value = $0 }
    return value
  }
}

extension Future {
  /// Convenience init for initializing a Future with a preset error
  convenience init(error: Failure) {
    self.init { promise in
      promise(.failure(error))
    }
  }
  
  /// Convenience init for initializing a Future with a preset value
  convenience init(value: Output) {
    self.init { promise in
      promise(.success(value))
    }
  }
  
  
}
