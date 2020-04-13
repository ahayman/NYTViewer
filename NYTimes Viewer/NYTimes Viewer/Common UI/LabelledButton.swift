import UIKit

class LabelledButton : PaddedLabel {
  
  typealias ButtonPress = () -> Void
  var onPress: ButtonPress? {
    didSet {
      let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
      tap.numberOfTapsRequired = 1
      tapRecognizer = tap
      self.isUserInteractionEnabled = true
      self.addGestureRecognizer(tap)
    }
  }
  
  func set(onPress: ButtonPress?) -> Self {
    self.onPress = onPress
    return self
  }
  
  private var tapRecognizer: UITapGestureRecognizer?
  @objc private dynamic func tapAction() { onPress?() }
}
