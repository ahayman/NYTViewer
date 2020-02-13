//
//  UIAlertController+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

/**
 The following extensions provide a somewhat comprehensive set of functions to display alerts and action sheets in a single-chained operation.
 This shortens up and clarifies the syntax, and makes it much easier to create alerts.  It also allows you to setup an alert and display it
 without needing to setup local storage.  For example, to create a simple Ok/Cancel alert:
 
 ```
 UIAlertController
 .alert("Alert Title", message: "User Message")
 .action("Ok") { _ in ... handle ok action }
 .cancel { _ in handle cancel action }
 .presentOn(self)
 ```
 
 This is much simpler and easier than separately creating the controller and actions, adding them, and then manually
 presenting the alert controller on a view controller.
 */
@objc public extension UIAlertController {
  
  /**
   Class constructor of an Alert Style controller with the provided title and optional message
   - parameters:
   - title: (optional) - The title of the alert
   - message: (optional) - The message to display
   - returns: A new UIAlertController with `.alert` style
   */
  class func alert(_ title: String? = nil, message: String? = nil) -> UIAlertController {
    return UIAlertController(title: title, message: message, preferredStyle: .alert)
  }
  
  /**
   Class constructor of an Action Sheet Style controller with the provided title and optional message
   - parameters:
   - title: (optional) - The title of the Action Sheet
   - message: (optional) - The message to display
   - returns: A new UIAlertController with `.ActionSheet` style
   */
  class func actionSheet(_ title: String? = nil, message: String? = nil) -> UIAlertController {
    return UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
  }
  
  /**
   Adds a Input Field to the Controller with a Save and Cancel buttons (configurable).
   The onInput closure will be called when the user clicks "Save"
  */
  func input(save: String = "Save", cancel: String = "Cancel", placeholder: String? = nil, inputType: UIKeyboardType = .default, keyboardAppearance: UIKeyboardAppearance = .default, onInput: @escaping (String?) -> Void) -> UIAlertController {
    var field: UITextField? = nil
    addTextField {
      $0.placeholder = placeholder
      $0.keyboardType = inputType
      $0.keyboardAppearance = keyboardAppearance
      field = $0
    }
    self.addAction(UIAlertAction(title: save, style: .default, handler: {  _ in
      onInput(field?.text)
    }))
    self.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { _ in }))
    return self
  }
  
  /**
   Chaining Constructor to add an action to the alert controller.
   This override allows objc clients to use default style and no handler for simplicity.
   - parameters:
   - action: The name (title) of the action
   - returns: self (for chaining)
   */
  @discardableResult func action(_ action: String) -> UIAlertController {
    self.addAction(UIAlertAction(title: action, style: .default, handler: nil))
    return self
  }
  
  /**
   Chaining Constructor to add an action to the alert controller.
   - parameters:
   - action: The name (title) of the action
   - style: The action style.  **Default:** `.Default`
   - onSelected: (Optional) A callback to use when the action is selected
   - returns: self (for chaining)
   */
  @discardableResult func action(_ action: String, style: UIAlertAction.Style = .default, onSelected: (() -> Void)? = nil) -> UIAlertController {
    self.addAction(UIAlertAction(title: action, style: style, handler: { _ in onSelected?() }))
    return self
  }
  
  @discardableResult func ok(_ action: String? = "OK", onOk: (() -> Void)? = nil) -> UIAlertController {
    self.addAction(UIAlertAction(title: action, style: .default, handler: { alert in
      onOk?()
    }))
    return self
  }

  /**
   Chaining Constructor to add a dismissal action to the alert controller.  When the action is selected, the provided callback will be called first, and then `attemptDismissal(animated: true)` will be called on self.
   - parameters:
   - action: The name (title) of the action
   - onCancel: (Optional) A callback to use when the action is selected
   - returns: self (for chaining)
   */
  @discardableResult func cancel(_ action: String? = "Cancel", onCancel: (() -> Void)? = nil) -> UIAlertController {
    self.addAction(UIAlertAction(title: action, style: .cancel, handler: { alert in
      onCancel?()
    }))
    return self
  }
  
  /**
   Chaining Constructor to add a destructive action to the alert controller.
   - parameters:
   - action: The name (title) of the action
   - onDestruct: The action to perform when the user selects this option.
   - returns: self (for chaining)
   */
  @discardableResult func destructive(_ action: String, onDestruct: @escaping (() -> Void)) -> UIAlertController {
    self.addAction(UIAlertAction(title: action, style: .destructive, handler: { action in
      onDestruct()
    }))
    return self
  }
  
  /**
   This will immediately present the alert controller onto the provided view controller.
   - parameters:
   - viewController: The view controller to present the alert controller on.
   - animated: Whether to animate the presentation.  **Default:** `true`
   
   - Warning: This should be the last thing you call or do with the alert controller, since it presents the alert to the user.
   */
  func presentOn(_ viewController: UIViewController, animated: Bool = true) {
    viewController.present(self, animated: animated, completion: nil)
  }
  
}
