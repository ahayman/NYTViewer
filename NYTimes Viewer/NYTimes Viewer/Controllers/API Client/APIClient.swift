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
   Retrieve articles from the API for the given request.
   - returns: a publisher that can be used to subscribe to the results
   */
  func getArticles(request: ArticleRequest) -> AnyPublisher<[Article], APIError>
}

/**
 Protocol for interacting with a URLSession.
 Listed functions are the only ones used.  In general, a URL Session will be used, but it can be
 replaced with a mock for unit tests.
 */
protocol NetworkSession {
  func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
  func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher
}

/// Conforming URLSession to NetworkSession for normal usage.
extension URLSession : NetworkSession {}

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
  func getArticles(request: ArticleRequest) -> AnyPublisher<[Article], APIError> {
    guard let req = request.request else { return Future(error: APIError.invalidURL).eraseToAnyPublisher() }
    return session
      .dataTaskPublisher(for: req)
      .tryMap { data, response in
        if let httpResponse = response as? HTTPURLResponse {
          guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.invalidCode(httpResponse.statusCode, String(data: data, encoding: .utf8) ?? "no data")
          }
        }
        guard data.count > 0 else { throw APIError.invalidResponse }
        return data
      }
      .decode(type: ArticleResponse.self, decoder: JSONDecoder())
      .mapError{ error -> APIError in
        if error is DecodingError {
          return APIError.decoding
        } else if let err = error as? APIError {
          return err
        } else {
          return APIError.invalidResponse
        }
      }
      .map { $0.results}
      .eraseToAnyPublisher()
  }
  
  /// Returns an a publisher to suscribe to an image retrieved for a URL
  func getImage(for url: URL) -> AnyPublisher<UIImage, APIError> {
    return session
      .dataTaskPublisher(for: url)
      .compactMap{ data, _ in
        return UIImage(data: data)
      }
      .mapError{ _ in APIError.invalidResponse }
      .eraseToAnyPublisher()
  }

}

/**
 Small private struct to handle the response instead of manually unpacking the JSON.
 */
private struct ArticleResponse : Decodable {
  let status: String
  let results: [Article]
  
  enum CodingKeys: String, CodingKey {
      case status, results
  }

  /**
   The decoding process uses a try/fail/try approach.  It's not the most efficient way to decode objects but
   it's pretty simple.
   
   Alternative: Match up the actual decoding objects with the request.  However, this would require adding a bit of complexity.
   Since this doesn't appear to be slowing the app down at all, we leave it as is.
   */
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.status = try container.decode(String.self, forKey: .status)
    if let standardArticles: [StandardArticle] = try? container.decode([StandardArticle].self, forKey: .results) {
      results = standardArticles
    } else {
      results = try container.decode([SharedArticle].self, forKey: .results)
    }
  }
  
}


