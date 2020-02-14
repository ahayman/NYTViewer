//
//  Result+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/14/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

extension Result {
  
  /**
   An easy way to retrieve the value on success without resorting to try.
   - returns: Success value on `.success`, `nil` otherwise.
   */
  var value: Success? {
    switch self {
    case .failure: return nil
    case .success(let value): return value
    }
  }
}
