//
//  MockAPIClient.swift
//  NYTimes ViewerTests
//
//  Created by Aaron Hayman on 2/17/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation
import Combine
@testable import NYTimes_Viewer

class MockAPIClient : APIClient {
  /**
   Instead of duplicating the functionality, we're simply wrapping the NYTClient and
   using the MockNetworkSession handle the mock data to save duplicating that data here.
   */
  var client: NYTClient = NYTClient(session: MockNetworkSession())
  
  var holdRequest: Bool = false {
    didSet {
      if !holdRequest {
        request.forEach{ $0() }
        request = []
      }
    }
  }

  private var request: [(() -> Void)] = []
  
  func get<T>(request: T) -> AnyPublisher<T.Response, APIError> where T : APIRequest {
    if holdRequest {
      return Future { promise in
        self.request.append({ _ = self.client.get(request: request).sink { promise($0) } })
      }.eraseToAnyPublisher()
    }
    return client.get(request: request)
  }
  
}
