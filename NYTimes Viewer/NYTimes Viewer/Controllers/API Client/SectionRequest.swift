//
//  SectionRequest.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/14/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

/**
 Section Struct for API Returns
 */
struct LatestSection : Decodable, Hashable {
  let section: String
  let display_name: String
}

/**
 A simple API Request object that request a section list from the server.
 It uses a JSONDecoder to convert the server data into SectionResponse type.
 */
struct SectionRequest : APIRequest {
  typealias Response = SectionResponse
  typealias Decoder = JSONDecoder
  
  var type: RequestType { return .get }
  var url: String { return "https://api.nytimes.com/svc/news/v3/content/section-list.json"}
  var parameters: [String : String] { return [ "api-key" : apiKey ] }
  var decodable: SectionResponse.Type { return SectionResponse.self }
  var decoder: JSONDecoder { return JSONDecoder() }
}

/**
 Expected response for Sections
 */
struct SectionResponse : Decodable {
  let status: String
  let results: [LatestSection?]
  
  enum CodingKeys: String, CodingKey {
    case status, results
  }
  
  /**
   Note: `nil` is being used for "All", so we always want to return that option, thus the custom decoding.
   */
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.status = try container.decode(String.self, forKey: .status)
    let sections = (try? container.decode([LatestSection].self, forKey: .results)) ?? []
    self.results = [nil] + sections
  }
  
}
