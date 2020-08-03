//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Thomas, Samuel B. (Student) on 6/17/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//
//could import Foundation
import SwiftUI
//func createCardContent

class EmojiMemoryGame: ObservableObject {
//   private(set) var model: MemoryGame<String>
   // or instead
    @Published private var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame() //MemoryGame<String>(numberOfPairsOfCards: 2) { _ in "😃" }
    //_ means unused
    //static makes it to the type
    private static func createMemoryGame() -> MemoryGame<String> {
        let emojis: Array<String> = ["👻","🎃","🕷"].shuffled()
        return MemoryGame<String>(numberOfPairsOfCards: emojis.count) { pairIndex in
            return emojis[pairIndex]
        }
    }
    // private var model
     var cards: Array<MemoryGame<String>.Card> {
          model.cards
     }
    
    //var objectWillChange: ObservableObjectPublisher
    
    //MARK: - Intent(s)
     
    func choose(card: MemoryGame<String>.Card){
        //objectWillChange.send() -- no longer needed 
        model.choose(card: card)
    }
    
    func resetGame() {
        model = EmojiMemoryGame.createMemoryGame()
    }
    
}

