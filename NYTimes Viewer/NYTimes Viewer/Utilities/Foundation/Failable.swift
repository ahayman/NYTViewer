//
//  Failable.swift
//  NYTimes Viewer
//
//  Created by Aaron Hayman on 2/14/20.
//  Copyright © 2020 Flexilesoft, LLC. All rights reserved.
//

import Foundation

/**
 This Failable is a way to decode arrays/dicts/etc in a way that will
 return the Failable (which ironically can't fail) and allow us to compact
 the results instead of failing the entire array/structure.
 
 This is useful if we want to allown an array of values to fail on the
 individual values without failing the entire array decode; from there we
 map out the failed decoding values.
 */
struct Failable<T : Decodable> : Decodable {
    let value: T?

    init(from decoder: Decoder) throws {
      self.value = try? decoder.singleValueContainer().decode(T.self)
    }
}
