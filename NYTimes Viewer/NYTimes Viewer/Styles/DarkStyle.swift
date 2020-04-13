//
//  DarkStyle.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 4/13/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

struct DarkFonts : Fonts {
  var header: UIFont = UIFont.preferredFont(forTextStyle: .headline)
  var cellTitle: UIFont = UIFont.preferredFont(forTextStyle: .title3)
  var cellSubTitle: UIFont = UIFont.preferredFont(forTextStyle: .subheadline)
  var cellSection: UIFont = UIFont.preferredFont(forTextStyle: .body)
  var cellDate: UIFont = UIFont.preferredFont(forTextStyle: .subheadline)
}

struct DarkColors : Colors {
  var primary: UIColor = UIColor(white: 0.96, alpha: 1)
  var secondary: UIColor = UIColor(white: 0.90, alpha: 1)
  var header: UIColor = UIColor(white: 0.95, alpha: 1)
  var background: UIColor = UIColor(white: 0.1, alpha: 1)
  var cellDivider: UIColor = .lightGray
  var selectedBackground: UIColor = .lightGray
  var selectedText: UIColor = .black
}
