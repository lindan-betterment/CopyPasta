//
//  Clip.swift
//  CopyPasta
//
//  Created by linda on 4/2/20.
//  Copyright © 2020 linda. All rights reserved.
//
import Foundation

struct Clip: Hashable, Codable {
    let key: String
    let text: String
}

extension Clip: CustomStringConvertible {
  var description: String {
    return "\(key): \(text)"
  }
}
