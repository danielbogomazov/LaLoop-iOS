//
//  Section.swift
//  LaLoop
//
//  Created by Daniel Bogomazov on 2019-05-02.
//  Copyright © 2018 Daniel Bogomazov. All rights reserved.
//

import Foundation

struct Section {
    var title: String
    var detail: String
    
    init(title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail ?? ""
    }
}
