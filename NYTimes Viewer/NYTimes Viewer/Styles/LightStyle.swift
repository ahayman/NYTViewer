//
//  LightStyle.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

struct LightFonts : Fonts {
  var header: UIFont = UIFont.preferredFont(forTextStyle: .headline)
  var cellTitle: UIFont = UIFont.preferredFont(forTextStyle: .title3)
  var cellSubTitle: UIFont = UIFont.preferredFont(forTextStyle: .subheadline)
  var cellSection: UIFont = UIFont.preferredFont(forTextStyle: .body)
  var cellDate: UIFont = UIFont.preferredFont(forTextStyle: .subheadline)
}

struct LightColors : Colors {
  var primary: UIColor = .darkText
  var secondary: UIColor = UIColor(hex: "#242424")!
  var header: UIColor = UIColor(hex: "#242424")!
  var background: UIColor = .white
  var cellDivider: UIColor = .darkGray
  var selectedBackground: UIColor = .darkGray
  var selectedText: UIColor = .white
}
