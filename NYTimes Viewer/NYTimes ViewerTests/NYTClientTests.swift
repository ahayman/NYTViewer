//
//  NYTClientTests.swift
//  NYTimes ViewerTests
//
//  Created by Aaron Hayman on 2/14/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import XCTest
import Combine
@testable import NYTimes_Viewer

private class NetworkMock : NetworkSession {
  func task(for request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), URLError> {
    return Future { promise in
      guard
        let url = request.url,
        let data = apiResponses[url.absoluteString]?.data(using: .utf8),
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
      else {
        promise(.failure(URLError(URLError.Code.badURL)))
        return
      }
      promise(.success((data, response)))
    }.eraseToAnyPublisher()
  }
}

class NYTClientTests: XCTestCase {
  var client: NYTClient = NYTClient(session: NetworkMock())
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  private func getFromClient(_ req: ArticleRequest) -> Result<ArticleResponse, APIError> {
    var result: Result<ArticleResponse, APIError>?
    let _ = client
      .get(request: req)
      .sink{ result = $0 }
    return result!
  }
  
  func testTopHomeAPI() {
    let result = getFromClient(.topStories(section: .home))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 56)
    for article in articles {
      XCTAssertTrue(article is StandardArticle)
      XCTAssertNotNil(article.media)
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testTopFashionAPI() {
    let result = getFromClient(.topStories(section: .fashion))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 9)
    for article in articles {
      XCTAssertTrue(article is StandardArticle)
      XCTAssertNotNil(article.media)
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
    XCTAssertEqual(articles[0].media?.count, 4, "The first media count should be 4, due to mis-named parameter in returned data.")
    for article in articles[1...] {
      XCTAssertEqual(article.media?.count, 5)
    }
  }
  
  func testTopTechAPI() {
    let result = getFromClient(.topStories(section: .technology))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 29)
    for article in articles {
      XCTAssertTrue(article is StandardArticle)
      XCTAssertNotNil(article.media)
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testTopWorldAPI() {
    let result = getFromClient(.topStories(section: .world))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 38)
    for article in articles {
      XCTAssertTrue(article is StandardArticle)
      XCTAssertNotNil(article.media)
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testMostViewedAPI() {
    let result = getFromClient(.mostViewed(last: .week))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 20)
    for (index, article) in articles.enumerated() {
      XCTAssertTrue(article is SharedArticle)
      if index == 11 {
        XCTAssertNil(article.media)
      } else {
        XCTAssertNotNil(article.media)
      }
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testMostSharedAllAPI() {
    let result = getFromClient(.mostShared(type: .all, last: .week))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 20)
    for article in articles {
      XCTAssertTrue(article is SharedArticle)
      XCTAssertNotNil(article.media)
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testMostSharedAllFacebook() {
    let result = getFromClient(.mostShared(type: .facebook, last: .week))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 20)
    for article in articles {
      XCTAssertTrue(article is SharedArticle)
      XCTAssertNotNil(article.media)
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testMostSharedAllTwitter() {
    let result = getFromClient(.mostShared(type: .twitter, last: .week))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 20)
    
    for (index, article) in articles.enumerated() {
      XCTAssertTrue(article is SharedArticle)
      if index == 0 {
        XCTAssertNil(article.media)
      } else {
        XCTAssertNotNil(article.media)
      }
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testLatestAllAPI() {
    let result = getFromClient(.latest(source: .all, section: .all))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 20)
    for article in articles {
      XCTAssertTrue(article is StandardArticle)
      XCTAssertNotNil(article.media)
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }

  func testLatestWorlAPI() {
    let result = getFromClient(.latest(source: .all, section: .section(name: "world", displayName: "World")))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 20)
    for (index, article) in articles.enumerated() {
      XCTAssertTrue(article is StandardArticle)
      if [5,8].contains(index) {
        XCTAssertNil(article.media)
      } else {
        XCTAssertNotNil(article.media)
      }
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testLatestTechAPI() {
    let result = getFromClient(.latest(source: .all, section: .section(name: "technology", displayName: "Technology")))
    guard let articles = result.value?.results else { return XCTFail("Should have received articles") }
    
    XCTAssertEqual(articles.count, 20)
    for (index, article) in articles.enumerated() {
      XCTAssertTrue(article is StandardArticle)
      if index == 13 {
        XCTAssertNil(article.media)
      } else {
        XCTAssertNotNil(article.media)
      }
      XCTAssertNotNil(article.abstract)
      XCTAssertNotNil(article.byline)
    }
  }
  
  func testSectionListAPI() {
    var result: Result<SectionResponse, APIError>?
    let _ = client
      .get(request: SectionRequest())
      .sink{ result = $0 }
    
    guard let sections = result?.value?.results else { return XCTFail("Should have received a section list.") }
    
    XCTAssertEqual(sections.count, 51)
    XCTAssertEqual(sections[0], .all)
  }
}
