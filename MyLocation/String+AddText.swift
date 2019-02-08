//
//  String+AddText.swift
//  MyLocation
//
//  Created by Phi Hoang Huy on 2/8/19.
//  Copyright © 2019 Phi Hoang Huy. All rights reserved.
//

extension String {
    mutating func add(text: String?,
                      separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text }
    } }
