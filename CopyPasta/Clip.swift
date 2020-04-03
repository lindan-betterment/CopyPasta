//
//  Clip.swift
//  CopyPasta
//
//  Created by linda on 4/2/20.
//  Copyright © 2020 linda. All rights reserved.
//
import SwiftUI
import Foundation

struct Clip {
    let key: String
    let text: String
  
    /*
  static let all: [Quote] =  [
    Quote(text: "Never put off until tomorrow what you can do the day after tomorrow.", author: "Mark Twain"),
    Quote(text: "Efficiency is doing better what is already being done.", author: "Peter Drucker"),
    Quote(text: "To infinity and beyond!", author: "Buzz Lightyear"),
    Quote(text: "May the Force be with you.", author: "Han Solo"),
    Quote(text: "Simplicity is the ultimate sophistication", author: "Leonardo da Vinci"),
    Quote(text: "It’s not just what it looks like and feels like. Design is how it works.", author: "Steve Jobs")
  ]
    */
}

extension Clip: CustomStringConvertible {
  var description: String {
    return "\(key): \(text)"
  }
}
