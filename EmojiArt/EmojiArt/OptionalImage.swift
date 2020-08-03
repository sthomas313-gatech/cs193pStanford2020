//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Thomas, Samuel B. (Student) on 7/6/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
