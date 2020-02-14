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
enum LatestSection : Decodable, Hashable {
  case all
  case section(name: String, displayName: String)
  
  enum CodingKeys: String, CodingKey {
    case section, display_name
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let section = try container.decode(String.self, forKey: .section)
    let display = try container.decode(String.self, forKey: .display_name)
    
    self = .section(name: section, displayName: display)
  }
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
  let results: [LatestSection]
  
  enum CodingKeys: String, CodingKey {
    case status, results
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.status = try container.decode(String.self, forKey: .status)
    let sections = (try? container.decode([Failable<LatestSection>].self, forKey: .results))?.compactMap{ $0.value } ?? []
    self.results = [.all] + sections
  }
  
}
