//
//  ArticleRequest.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/14/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

private let basePopularURL = "https://api.nytimes.com/svc/mostpopular/v2/"
private let baseNewsURL = "https://api.nytimes.com/svc/news/v3/"
private let baseTopURL = "https://api.nytimes.com/svc/topstories/v2/"



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
 The actual requests available to retrieve articles from the NYT Api.
 */
enum ArticleRequest : APIRequest {
  typealias Response = ArticleResponse
  typealias Decoder = JSONDecoder
  
  case topStories(section: ArticleSection)
  case mostViewed(last: ArticleInterval)
  case mostShared(type: ArticleShareType, last: ArticleInterval)
  case mostEmailed(last: ArticleInterval)
  case latest(source: ArticleSource, section: LatestSection?)
  
  var type: RequestType { return .get }
  
  var url: String {
    switch self {
    case let .topStories(section): return "\(baseTopURL)\(section.rawValue).json"
    case let .mostViewed(period): return "\(basePopularURL)viewed/\(period.rawValue).json"
    case let .mostShared(.all, period): return "\(basePopularURL)shared/\(period.rawValue).json"
    case let .mostShared(type, period): return "\(basePopularURL)shared/\(period.rawValue)/\(type.rawValue).json"
    case let .mostEmailed(period): return "\(basePopularURL)emailed/\(period.rawValue).json"
    case let .latest(source, .some(section)): return "\(baseNewsURL)content/\(source.rawValue)/\(section.section).json"
    case let .latest(source, .none): return "\(baseNewsURL)content/\(source.rawValue)/all.json"
    }
  }
  
  var parameters: [String : String] {
    return [ "api-key" : apiKey ]
  }
  
  var decodable: ArticleResponse.Type { return ArticleResponse.self }
  var decoder: JSONDecoder { return JSONDecoder() }
}

/**
 Small expected response for articles
 */
struct ArticleResponse : Decodable {
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
