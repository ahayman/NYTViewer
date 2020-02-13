//
//  CGFloat+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

extension CGFloat {
  var ceiling: CGFloat {
    return ceil(self)
  }
  var floored: CGFloat {
    return floor(self)
  }
  var absolute: CGFloat {
    return self < 0 ? self * -1 : self
  }
  var squared: CGSize {
    return CGSize(squared: self)
  }
}
