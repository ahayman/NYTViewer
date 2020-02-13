//
//  LabelledButton.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/11/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

class LabelledButton : BaseLabel {
  
  typealias ButtonPress = () -> Void
  var onPress: ButtonPress? {
    didSet {
      let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
      tap.numberOfTapsRequired = 1
      tapRecognizer = tap
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
