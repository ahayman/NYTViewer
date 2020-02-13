//
//  UIColor+Extensions.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/10/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import UIKit

extension UIColor {
  public convenience init?(hex: String) {
    var hexColor = hex.hasPrefix("#") ? String(hex[hex.index(after: hex.startIndex)...]) : hex
    if hexColor.count == 1 {
      hexColor = "\(hexColor)\(hexColor)\(hexColor)\(hexColor)\(hexColor)\(hexColor)ff"
    } else if hexColor.count == 2 {
      hexColor = "\(hexColor)\(hexColor)\(hexColor)ff"
    } else if (3...4).contains(hexColor.count) {
      hexColor = hexColor.reduce("") { "\($0)\($1)\($1)"}
    }
    if hexColor.count == 6 {
      hexColor += "ff"
    }
    if hexColor.count > 8 {
      hexColor = hexColor.subSequence(0..<8).string
    }
    if hexColor.count == 8 {
      let scanner = Scanner(string: hexColor)
      var hexNumber: UInt64 = 0
      
      if scanner.scanHexInt64(&hexNumber) {
        let r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        let g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        let b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        let a = CGFloat(hexNumber & 0x000000ff) / 255
        
        self.init(red: r, green: g, blue: b, alpha: a)
        return
      }
    }
    
    return nil
  }
}
