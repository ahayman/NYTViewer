import UIKit

protocol Fonts {
  var header: UIFont { get }
  var cellTitle: UIFont { get }
  var cellSubTitle: UIFont { get }
  var cellSection: UIFont { get }
  var cellDate: UIFont { get }
}

protocol Colors {
  var primary: UIColor { get }
  var secondary: UIColor { get }
  var header: UIColor { get }
  var background: UIColor { get }
  var cellDivider: UIColor { get }
  var selectedBackground: UIColor { get }
  var selectedText: UIColor { get }
}

/**
 Eventually, replace with something dynamic
 */
let styleColors: Colors = LightColors()
let styleFonts: Fonts = LightFonts()

protocol Style {
  associatedtype Element
  @discardableResult static func apply(to element: Element) -> Element
  static func new() -> Element
}

extension Style {
  static func apply(to elements: [Element]) {
    elements.forEach{ apply(to: $0) }
  }
}

struct Styles {
  
  struct Background : Style {
    typealias Element = UIView
    static func new() -> Element { return apply(to: UIView()) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.backgroundColor = styleColors.background
      return element
    }
  }
  
  struct Header : Style {
    typealias Element = BaseLabel
    static func new() -> Element { return apply(to: BaseLabel()) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.textColor = styleColors.header
      element.font = styleFonts.header
      return element
    }
  }
  
  struct CellTitle : Style {
    typealias Element = BaseLabel
    static func new() -> Element { return apply(to: BaseLabel()) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.textColor = styleColors.primary
      element.font = styleFonts.cellTitle
      element.numberOfLines = 1
      return element
    }
  }
  
  struct CellSubtitle : Style {
    typealias Element = BaseLabel
    static func new() -> Element { return apply(to: BaseLabel()) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.textColor = styleColors.secondary
      element.font = styleFonts.cellSubTitle
      return element
    }
  }
  
  struct CellDate : Style {
    typealias Element = BaseLabel
    static func new() -> Element { return apply(to: BaseLabel()) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.textColor = styleColors.secondary
      element.font = styleFonts.cellDate
      return element
    }
  }
  
  struct CellContent : Style {
    typealias Element = BaseLabel
    static func new() -> Element { return apply(to: BaseLabel()) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.textColor = styleColors.primary
      element.font = styleFonts.cellSection
      element.numberOfLines = 3
      return element
    }
  }
  
  struct CellImage : Style {
    typealias Element = UIImageView
    static func new() -> Element { return apply(to: UIImageView(frame: .zero)) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.clipsToBounds = true
      element.contentMode = .scaleAspectFill
      return element
    }
  }
  
  struct HR : Style {
    typealias Element = UIView
    static func new() -> Element { return apply(to: UIView(frame: .zero)) }
    
    @discardableResult static func apply(to element: Element) -> Element {
      element.layer.cornerRadius = 1.0
      element.backgroundColor = styleColors.cellDivider
      return element
    }
  }
  
  struct RefreshIndicator : Style {
    typealias Element = UIRefreshControl
    static func new() -> Element { return apply(to: UIRefreshControl()) }
    
    @discardableResult static func apply(to element: UIRefreshControl) -> UIRefreshControl {
      element.tintColor = styleColors.secondary
      return element
    }
  }
  
  struct SegmentUnselected : Style {
    typealias Element = LabelledButton
    static func new() -> Element { return apply(to: LabelledButton()) }
    
    @discardableResult static func apply(to element: Element) -> Element  {
      element.padding = BaseLabel.Padding(all: 5.0)
      element.backgroundColor = .clear
      element.textColor = styleColors.primary
      element.layer.cornerRadius = 5.0
      return element
    }
  }
  
  struct SegmentSelected : Style {
    typealias Element = LabelledButton
    static func new() -> Element { return apply(to: LabelledButton()) }
    
    @discardableResult static func apply(to element: Element) -> Element  {
      element.padding = BaseLabel.Padding(all: 5.0)
      element.backgroundColor = styleColors.selectedBackground
      element.textColor = styleColors.selectedText
      element.layer.cornerRadius = 5.0
      return element
    }
  }
  
}

