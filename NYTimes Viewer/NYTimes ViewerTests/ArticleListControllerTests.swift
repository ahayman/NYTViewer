//
//  ArticleListControllerTests.swift
//  NYTimes ViewerTests
//
//  Created by Aaron Hayman on 2/17/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import XCTest
import Combine
@testable import NYTimes_Viewer

class ArticleListControllerTests : XCTestCase {

  func testInitialContent() {
    let controller = ArticleListController(apiClient: MockAPIClient())
    XCTAssertEqual(controller.content, ArticleContent.top(section: .home))
    
    XCTAssertEqual(controller.articles.lastValue?.count, 0)
    XCTAssertEqual(controller.loading.lastValue, false)
    XCTAssertEqual(controller.latestSections.lastValue, [.all])
  }
  
  func testInitialLoad() {
    let controller = ArticleListController(apiClient: MockAPIClient())
    
    controller.reloadContent()
    
    let expectedArticles = responseArticles(for: .topStories(section: .home))
    XCTAssertNotNil(expectedArticles)
    let articles = controller.articles.lastValue
    XCTAssertNotNil(articles)
    XCTAssertEqual(articles?.map { $0.title }, expectedArticles?.map{ $0.title })
    
    let expectedSections = responseSections(for: SectionRequest())
    XCTAssertNotNil(expectedSections)
    let sections = controller.latestSections.lastValue
    XCTAssertNotNil(sections)
    XCTAssertEqual(expectedSections, sections)
  }
  
  func testContentUpdate() {
    let controller = ArticleListController(apiClient: MockAPIClient())
    controller.reloadContent()
    
    controller.content = .top(section: .world)
    
    let expectedArticles = responseArticles(for: .topStories(section: .world))
    XCTAssertNotNil(expectedArticles)
    let articles = controller.articles.lastValue
    XCTAssertNotNil(articles)
    XCTAssertEqual(articles?.map { $0.title }, expectedArticles?.map{ $0.title })
  }
  
  func testLoadingIndicator() {
    let client = MockAPIClient()
    client.holdRequest = true
    
    let controller = ArticleListController(apiClient: client)
    XCTAssertEqual(controller.loading.lastValue, false)

    controller.reloadContent()
    
    XCTAssertEqual(controller.loading.lastValue, true)
    
    client.holdRequest = false
    
    XCTAssertEqual(controller.loading.lastValue, false)

  }

}
