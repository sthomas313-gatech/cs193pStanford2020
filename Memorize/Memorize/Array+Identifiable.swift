//
//  Array+Identifiable.swift
//  Memorize
//
//  Created by Thomas, Samuel B. (Student) on 6/24/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
   func firstIndex(matching: Element) -> Int? {
        for index in 0..<self.count {
            if self[index].id == matching.id {
               return index
            }
        }
        return nil// TODO: bogus!!
    //nil - If a constant or variable in your code needs to work with the absence of a value under certain conditions, always declare it as an optional value of the appropriate type
    }
}
