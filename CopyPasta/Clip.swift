//
//  Clip.swift
//  CopyPasta
//
//  Created by linda on 4/8/20.
//  Copyright © 2020 linda. All rights reserved.
//

import Foundation

struct Clip {
    let hash: String
    let timestamp: Int64
    let menu_view: String
    let data: NSCoding
    init(pb_hash: String, change_timestamp: Int64, menu_string: String, item: NSCoding) {
        self.hash = pb_hash
        self.timestamp = change_timestamp
        self.menu_view = menu_string
        self.data = item
    }
}
