//
//  APIClient.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit
import Combine

/**
 API Client protocol for retrieving articles
 Generally, the APIClient should be referenced instead of a concrete class
 */
protocol APIClient {
  /**
   Retrieve decodable data
   - returns: a publisher that can be used to subscribe to the results
   */
  func get<T:APIRequest>(request: T) -> AnyPublisher<T.Response, APIError>
}

/**
 Protocol for interacting with a URLSession.
 Listed functions are the only ones used.  In general, a URL Session will be used, but it can be
 replaced with a mock for unit tests.
 */
protocol NetworkSession {
  func task(for request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), URLError>
}

/**
 Simple API errors.
 */
enum APIError : LocalizedError {
  case invalidURL
  case decoding
  case invalidCode(Int, String)
  case invalidResponse
}


/// Conforming URLSession to NetworkSession for normal usage.
extension URLSession : NetworkSession {
  
  func task(for request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), URLError> {
    return self
      .dataTaskPublisher(for: request.url!)
      .tryMap{ (data: Data, response: URLResponse) in
        guard let httpRes = response as? HTTPURLResponse else { throw URLError(URLError.Code.badServerResponse) }
        return (data, httpRes)
      }
      .mapError{ return ($0 as? URLError) ?? URLError(URLError.Code.badServerResponse) }
      .eraseToAnyPublisher()
  }
  
  func task(for url: URL) -> AnyPublisher<(Data, HTTPURLResponse), URLError> {
    return task(for: URLRequest(url: url))
  }
  
}

/**
 Concrete API Client that handles requests to get articles and images from the NY Times API.
 */
class NYTClient : APIClient {
  private let session: NetworkSession
  
  /**
   For standard usage, initialize either with a specific URLSession (defaults to `URLSession.shared`).
   Pass in a mock NetworkSession for testing
   */
  init(session: NetworkSession = URLSession.shared) {
    self.session = session
  }
  
  /// Retrieve articels for a 'request'.  See ArticleRequest for more information on what kinds of requests can be made.
  func get<T:APIRequest>(request: T) -> AnyPublisher<T.Response, APIError> {
    guard let req = request.request else { return Future(error: APIError.invalidURL).eraseToAnyPublisher() }
    return session
      .task(for: req)
      .tryMap { data, response in
        guard (200..<300).contains(response.statusCode) else {
          throw APIError.invalidCode(response.statusCode, String(data: data, encoding: .utf8) ?? "no data")
        }
        guard data.count > 0 else { throw APIError.invalidResponse }
        return data
    }
    .decode(type: request.decodable, decoder: request.decoder)
    .mapError{ error -> APIError in
      if error is DecodingError {
        return APIError.decoding
      } else if let err = error as? APIError {
        return err
      } else {
        return APIError.invalidResponse
      }
    }
    .eraseToAnyPublisher()
  }

  /// Returns an a publisher to suscribe to an image retrieved for a URL
  func getImage(for url: URL) -> AnyPublisher<UIImage, APIError> {
    return session
      .task(for: URLRequest(url: url))
      .compactMap{ data, _ in return UIImage(data: data) }
      .mapError{ _ in APIError.invalidResponse }
      .eraseToAnyPublisher()
  }

}



