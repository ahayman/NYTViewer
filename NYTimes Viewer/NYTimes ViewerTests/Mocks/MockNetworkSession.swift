//
//  MockNetworkSession.swift
//  NYTimes ViewerTests
//
//  Created by Aaron Hayman on 2/17/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation
import Combine

class MockNetworkSession : NetworkSession {
  func task(for request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), URLError> {
    return Future { promise in
      guard let url = request.url else {
        promise(.failure(URLError(URLError.Code.badURL)))
        return
      }
      guard
        let data = apiResponses[url.absoluteString]?.data(using: .utf8),
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        else {
          if let res = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil) {
            promise(.success(("Unmocked URL".data(using: .utf8) ?? Data(), res)))
          } else {
            promise(.failure(URLError(URLError.Code.badURL)))
          }
          return
      }
      promise(.success((data, response)))
    }.eraseToAnyPublisher()
  }
}

