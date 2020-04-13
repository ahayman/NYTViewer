import UIKit

extension UILabel {
  
  func setTextAlignment(_ textAlignment: NSTextAlignment) -> Self {
    self.textAlignment = textAlignment
    return self
  }
  
  @discardableResult func setText(_ text: String?) -> Self {
    self.text = text
    return self
  }
  
  func setFont(_ font: UIFont) -> Self {
    self.font = font
    return self
  }
  
  func setTextColor(_ textColor: UIColor) -> Self {
    self.textColor = textColor
    return self
  }
  
  func setNumberOfLines(_ numberOfLines: Int) -> Self {
    self.numberOfLines = numberOfLines
    return self
  }

  func setLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
    self.lineBreakMode = lineBreakMode
    return self
  }

}
