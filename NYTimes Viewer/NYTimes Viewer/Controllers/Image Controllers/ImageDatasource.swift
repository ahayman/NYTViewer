import UIKit
import Combine

/**
 The primary protocol for retrieving images asynchronously
 */
protocol ImageDatasource {
  func getImage(for: URL) -> AnyPublisher<UIImage, APIError>
}

/**
 The ways retrieving an image can fail.
 We'll want to expand this to include API errors eventually.
 */
enum ImageSourceError : LocalizedError {
  case NoImageAvailable
  case APIError(APIError)
}
