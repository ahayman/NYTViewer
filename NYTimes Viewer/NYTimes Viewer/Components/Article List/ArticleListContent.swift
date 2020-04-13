import UIKit
import Combine

/**
 Many NYT APIs requests for articles require a section.  These are the sections available.
 Note: the case names match the string names required by the API.  IOW: renaming them will break them.
 */
enum ArticleSection : String, CaseIterable {
  case arts, automobiles, books, business, fashion, food, health, home, insider, magazine, movies, nyregion, obituaries, opinion, politics, realestate, science, sports, sundayreview, technology, theater, travel, upshot, us, world
  
  init(displayName: String) {
    self = ArticleSection.allCases.first(where: { $0.displayName == displayName }) ?? .home
  }
  
  var displayName: String {
    switch self {
    case .arts: return "Arts"
    case .automobiles: return "Automobiles"
    case .books: return "Books"
    case .business: return "Business"
    case .fashion: return "Fashion"
    case .food: return "Food"
    case .health: return "Health"
    case .home: return "Home"
    case .insider: return "Insider"
    case .magazine: return "Magazine"
    case .movies: return "Movies"
    case .nyregion: return "NY Region"
    case .obituaries: return "Obituaries"
    case .opinion: return "Opinion"
    case .politics: return "Politics"
    case .realestate: return "Real Estate"
    case .science: return "Science"
    case .sports: return "Sports"
    case .sundayreview: return "Sunday Review"
    case .technology: return "Tech"
    case .theater: return "Theater"
    case .travel: return "Travel"
    case .upshot: return "Upshot"
    case .us: return "US"
    case .world: return "World"
    }
  }
}

/**
 Yes, there are more share types.  No, I couldn't find them.  I took the ones below based on their examples.
 Yes, it's annoying.
 */
enum ArticleShareType : String, CaseIterable {
  case all
  case facebook
  case twitter
  
  init(displayName: String) {
    self = Self.allCases.first(where: { $0.displayName == displayName }) ?? .all
  }
  
  var displayName: String {
    switch self {
    case .all: return "All"
    case .facebook: return "Facebook"
    case .twitter: return "Twitter"
    }
  }
}

/**
 The top-most article content available to the user.
 */
enum ArticleContent : Hashable {
  static var displayNames: [String] = [ArticleContent.latest(section: .all), ArticleContent.top(section: .home), .mostViewed, .mostShared(type: .all)].map{ $0.displayName }

  case latest(section: LatestSection)
  case top(section: ArticleSection)
  case mostViewed
  case mostShared(type: ArticleShareType)
  
  var displayName: String {
    switch self {
    case .latest: return "Latest"
    case .top: return "Top"
    case .mostViewed: return "Most Viewed"
    case .mostShared: return "Most Shared"
    }
  }
}


