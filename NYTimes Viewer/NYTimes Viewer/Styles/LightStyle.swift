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
  var secondary: UIColor = UIColor(white: 0.14, alpha: 1)
  var header: UIColor = UIColor(white: 0.14, alpha: 1)
  var background: UIColor = .white
  var cellDivider: UIColor = .darkGray
  var selectedBackground: UIColor = .darkGray
  var selectedText: UIColor = .white
}
