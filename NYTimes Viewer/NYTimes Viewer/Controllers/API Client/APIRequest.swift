//
//  APIRequest.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

private let basePopularURL = "https://api.nytimes.com/svc/mostpopular/v2/"
private let baseNewsURL = "https://api.nytimes.com/svc/news/v3/"
private let baseTopURL = "https://api.nytimes.com/svc/topstories/v2/"

/// Not Secure: Normally we'd want to download this from a secure server.
private let apiKey = "3L0gAAnMGB3TtBTiYltEzaWVZK1mMKmA"

/**
 Defines the type of request.  I'm only including the most common for brevity's sake, and .post isn't getting used.  I only add it for the sake of completeness.
 */
enum RequestType {
  case get
  case post
}

/**
 A protocol that defines a basic API request.
 */
protocol APIRequest {
  var type: RequestType { get }
  var url: String { get }
  var parameters: [String:String] { get }
}

/**
 This extension turns the APIRequirest into a URLRequest, which is used as the primary object for making requests from URLSession
 */
extension APIRequest {
  var request: URLRequest? {
    var components = URLComponents(string: self.url)
    if case .get = type, !parameters.isEmpty {
      components?.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
    }
    guard let url = components?.url else { return nil }
    var req = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 5.0)
    switch type {
    case .get: req.httpMethod = "GET"
    case .post:
      req.httpMethod = "POST"
      if parameters.isNotEmpty {
        req.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
      }
    }
    return req
  }
}

/**
 Some NYT API's require a Source.  I believe: all = all (gasp), nyt = New York Times only articles, inyt = uh... maybe affiliate articles, like "associated press"
 */
enum ArticleSource : String {
  case all, nyt, inyt
}

/**
 Time interval for retrieving articles (past day, week, month)
 */
enum ArticleInterval : Int {
  case day = 1
  case week = 7
  case month = 30
}

/**
 Simple API errors.  Should be expanded later.
 */
enum APIError : LocalizedError {
  case invalidURL
  case decoding
  case invalidCode(Int, String)
  case invalidResponse
}

/**
 The actual requests available to retrieve articles from the NYT Api.
 */
enum ArticleRequest : APIRequest {
  case topStories(section: ArticleSection)
  case mostViewed(last: ArticleInterval)
  case mostShared(type: ArticleShareType, last: ArticleInterval)
  case mostEmailed(last: ArticleInterval)
  case latest(source: ArticleSource, section: ArticleSection)
  
  var type: RequestType { return .get }
  
  var url: String {
    switch self {
    case let .topStories(section): return "\(baseTopURL)\(section.rawValue).json"
    case let .mostViewed(period): return "\(basePopularURL)viewed/\(period.rawValue).json"
    case .mostShared(.all, let period): return "\(basePopularURL)shared/\(period.rawValue).json"
    case let .mostShared(type, period): return "\(basePopularURL)shared/\(period.rawValue)/\(type.rawValue).json"
    case let .mostEmailed(period): return "\(basePopularURL)emailed/\(period.rawValue).json"
    case let .latest(source, section): return "\(baseNewsURL)content/\(source.rawValue)/\(section.rawValue).json"
    }
  }
  
  var parameters: [String : String] {
    return [ "api-key" : apiKey ]
  }
}
