//
//  APIRequest.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation
import Combine

/// Not Secure: Normally we'd want to download this from a secure server.
let apiKey = "3L0gAAnMGB3TtBTiYltEzaWVZK1mMKmA"

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
  associatedtype Response: Decodable
  associatedtype Decoder: TopLevelDecoder where Decoder.Input == Data
  var type: RequestType { get }
  var url: String { get }
  var parameters: [String:String] { get }
  var decodable: Response.Type { get }
  var decoder: Decoder { get }
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

