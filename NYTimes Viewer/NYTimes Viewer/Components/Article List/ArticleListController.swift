//
//  ArticleListController.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/11/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation
import Combine

/// We only want to refresh the cache/reload data for a request once every 30 seconds
let cacheDebounce: TimeInterval = 30

/**
 Concrete implementation of ArticleListDatasource
 */
class ArticleListController : ArticleListDatasource {

  // A simple caching structure to keep track of the date the articles were last updated
  private struct CachedArticles {
    let date: Date
    let data: [Article]
  }
  
  /**
   Represents Currently displayed content.
   Setting this will cause the article list to be updated.
   Subscribe to the `articles` publisher to be notified of changes.
   */
  var content: ArticleContent = .top(section: .home) {
    didSet {
      updateLoading()
      
      /// Update `articles` from cache, if any, and trigger new data load if applicable
      if let cached = cache[content] {
        _articles = cached.data
        if Date().distance(to: cached.date) > cacheDebounce {
          load(content: content)
        }
      } else {
        _articles = []
        load(content: content)
      }
    }
  }
  
  // Updated whenever the current content is loading
  var loading: Published<Bool>.Publisher { return $_loading }
  
  // The current article list
  var articles: Published<[Article]>.Publisher { return $_articles }
  @Published private var _articles: [Article]
  
  var latestSections: Published<[LatestSection]>.Publisher { return $_sections }
  @Published private var _sections: [LatestSection]
  private var sectionLoading: Cancellable?
  
  
  private var api: APIClient
  @Published private var _loading: Bool
  
  /**
   Each article request is cached.
   This isn't exactly the most efficient caching system; a lot of articles will be duplicated.
   But the actual article size is small and this is a lot easier than implementing something more complex.
   Prefer simplicity over premature optimization.
   */
  private var cache: [ArticleContent:CachedArticles] = [:]
  
  /**
   We only allow one network request per article content.  Logic should prevent
   duplicate requests.
   */
  private var networkRequests: [ArticleContent:AnyCancellable] = [:]
  
  /**
   We only need an APIClient.  It's a protocol, so it can be mocked for testing.
   */
  init(apiClient: APIClient) {
    self.api = apiClient
    self._loading = false
    self._articles = []
    self._sections = [.all]
  }
  
  /**
   Public function to force re-loading of the current content.
   Note: This will bypass the standard cache debounce but it will not
   allow duplicate requests.
   */
  func reloadContent() {
    load(content: content)
    loadSections()
  }

  /// Updates the loading parameter
  private func updateLoading() {
    _loading = networkRequests[content] != nil
  }
  
  private func loadSections() {
    guard sectionLoading == nil else { return }
    sectionLoading = api
      .get(request: SectionRequest())
      .sink{ [weak self] (response: Result<SectionResponse, APIError>) in
        guard let this = self else { return }
        this.sectionLoading = nil
        this._sections = response.value?.results ?? [.all]
      }
  }
  
  /**
   Will load a new article request for the content if a pending request isn't already in progress
   */
  private func load(content: ArticleContent) {
    guard networkRequests[content] == nil else { return }
    
    let request: ArticleRequest
    switch content {
    case .latest(let section): request = .latest(source: .all, section: section)
    case .mostShared(let type): request = .mostShared(type: type, last: .week)
    case .mostViewed: request = .mostViewed(last: .week)
    case .top(let section): request = .topStories(section: section)
    }
    
    networkRequests[content] = api
      .get(request: request)
      .sink { [weak self] (result: Result<ArticleResponse, APIError>) in
        guard let this = self else { return }
        this.networkRequests[content] = nil
        if case .success(let response) = result {
          this.cache[content] = CachedArticles(date: Date(), data: response.results)
          if this.content == content {
            this._articles = response.results
          }
        }
        this.updateLoading()
      }
    
    updateLoading()
  }

}
