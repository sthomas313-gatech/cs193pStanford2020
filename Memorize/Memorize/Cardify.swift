//
//  Cardify.swift
//  Memorize
//
//  Created by Thomas, Samuel B. (Student) on 6/25/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var rotation: Double
    
    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    var isFaceUp: Bool {
        rotation < 90
    }
    var animatableData: Double {
        get {return rotation}
        set {rotation = newValue}
    }
    
    func body(content: Content) -> some View {
        ZStack {
            //if isFaceUp {
            Group {
                //front
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
                content
            }
            .opacity(isFaceUp ? 1 : 0)
           // } else {
                //back
                RoundedRectangle(cornerRadius: cornerRadius).fill()
            .opacity(isFaceUp ? 0 : 1)
           // }
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0,1,0))
    }
    
    private let cornerRadius: CGFloat = 10
    private let edgeLineWidth: CGFloat = 3
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
