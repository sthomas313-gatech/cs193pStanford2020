//
//  Array+Only.swift
//  Memorize
//
//  Created by Thomas, Samuel B. (Student) on 6/24/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
