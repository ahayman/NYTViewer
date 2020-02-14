//
//  Article.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

/**
 Generic article returned from the API.
 This protocol defines the primary variables we need from the api results.
 The api returns several different structures, which must be decoded separately.
 */
protocol Article {
  var title: String { get }
  var byline: String? { get }
  var abstract: String? { get }
  var url: String { get }
  var media: [Media]? { get }
}

/**
 Generic Media type (basically, for images, although video could be included)
 This protocol defines the primary variables we need from the api results.
 The api returns several different structures, which must be decoded separately.
 */
protocol Media {
  var caption: String? { get }
  var height: Int { get }
  var width: Int { get }
  var url: String { get }
  var type: String { get }
}

/**
 Most of the API endpoints return a standard Articles in this structure.
 */
struct StandardArticle : Decodable, Article {
  var media: [Media]? { return multimedia }
  let title: String
  let byline: String?
  let abstract: String?
  let url: String
  let item_type: String
  var multimedia: [StandardMedia]?
  
  private enum CodingKeys : String, CodingKey {
    case title
    case byline
    case abstract
    case url
    case item_type
    case multimedia
  }
  
  /**
   We decode this ourselves for a primary reason: the API returns an empty string ("") for empty arrays.
   This requires us to manually decode and use a try? for the multimedia decode, or else we'll end up
   with the entire results failing to decode if any of the multimedia arrays are empty.
   */
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decode(String.self, forKey: .title)
    byline = try? container.decode(String.self, forKey: .byline)
    abstract = try? container.decode(String.self, forKey: .abstract)
    url = try container.decode(String.self, forKey: .url)
    item_type = try container.decode(String.self, forKey: .item_type)
    multimedia = (try? container.decode([Failable<StandardMedia>].self, forKey: .multimedia))?.compactMap{ $0.value }
  }
}

/**
 Most of the API endpoings returns standard media in this structure
 */
struct StandardMedia : Decodable, Media {
  let caption: String?
  let height: Int
  let width: Int
  let url: String
  let type: String
}

/**
 API endpoints dealing with "shared" or "viewed" metrics can be handles by this structure.
 This includes social media shares, most/top viewed, etc.
 */
struct SharedArticle : Decodable, Article {
  let title: String
  let byline: String?
  let abstract: String?
  let url: String
  let multimedia: [SharedMedia]?
  var media: [Media]? { return multimedia }
  
  private enum CodingKeys : String, CodingKey {
    case title
    case byline
    case abstract
    case url
    case multimedia = "media"
  }
  
  /**
   We decode this ourselves for a primary reason: the API returns an empty string ("") for empty arrays.
   This requires us to manually decode and use a try? for the multimedia decode, or else we'll end up
   with the entire results failing to decode if any of the multimedia arrays are empty.
   */
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decode(String.self, forKey: .title)
    byline = try? container.decode(String.self, forKey: .byline)
    abstract = try? container.decode(String.self, forKey: .abstract)
    url = try container.decode(String.self, forKey: .url)
    multimedia = (try? container.decode([Failable<SharedMedia>].self, forKey: .multimedia))?.compactMap{ $0.value }
  }
}

/**
 The SharedMedia structure.
 Note:  SharedMedia is structured with primary information (type, caption, etc)
 along with an array of "sizes".  At the moment, we're keeping things simple
 and only using the first item in those sizes.  This is done for simplicity, but
 we may want to look at changing it later.
 */
struct SharedMedia : Decodable, Media {

  var height: Int { return mediaMetadata?.first?.height ?? 0 }
  var width: Int { return mediaMetadata?.first?.width ?? 0 }
  var url: String { return mediaMetadata?.first?.url ?? "" }
  
  let caption: String?
  let type: String
  let mediaMetadata: [SharedMetadata]?

  private enum CodingKeys : String, CodingKey {
    case caption
    case type
    case mediaMetadata = "media-metadata"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    caption = try? container.decode(String.self, forKey: .caption)
    type = try container.decode(String.self, forKey: .type)
    mediaMetadata = (try? container.decode([Failable<SharedMetadata>].self, forKey: .mediaMetadata))?.compactMap{ $0.value }
  }
  
}

/**
 Essentially defines a "size" for a specific image.
 */
struct SharedMetadata : Decodable {
  let height: Int
  let width: Int
  let url: String
}
