//
//  MemoryGame.swift
//  Memorize
//
//  Created by Thomas, Samuel B. (Student) on 6/17/20.
//  Copyright © 2020 Thomas, Samuel B. (Student). All rights reserved.
//

//swift has to be strongly typed

import Foundation
//generic type variable
struct MemoryGame<CardContent> where CardContent: Equatable{
    //vars
    private(set) var cards: Array<Card>
    
    private var indexOfTheOnceAndOnlyFaceUpCard: Int? {//=nil
        get {
            cards.indices.filter{ cards[$0].isFaceUp }.only}
//            var faceUpCardIndices = [Int]()
//            for index in cards.indices {
//                if cards[index].isFaceUp {
//                    faceUpCardIndices.append(index)
//                }
//            }
//            if faceUpCardIndices.count == 1 {
//                return faceUpCardIndices.first
//            } else {
//                return nil
//            }
        //}
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue
               
            }
        }
    }
    
    //calling choose with an object card
    //arguments are set to lets
    mutating func choose(card: Card) {
        //print("Card chosen: \(card)")
        if let chosenIndex: Int = cards.firstIndex(matching: card), !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOnceAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                //indexOfTheOnceAndOnlyFaceUpCard = nil
            } else {
//                for index in cards.indices {
//                    cards[index].isFaceUp = false
//                }
                indexOfTheOnceAndOnlyFaceUpCard = chosenIndex
            }
            self.cards[chosenIndex].isFaceUp = true
        }
    }
//
//    func index(of card: Card) -> Int {
//        for index in 0..<self.cards.count {
//            if self.cards[index].id == card.id {
//                return index
//            }
//        }
//        return 0 // TODO: bogus!
//    }
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id:pairIndex*2+1))
        }
        cards.shuffle()
    }
    
    //struct in a struct for naming
    struct Card: Identifiable {
        var isFaceUp: Bool = false{
            didSet{
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched: Bool = false {
            didSet{
               stopUsingBonusTime()
            }
        }
        var content: CardContent
        var id: Int
        
        
        //MARK: - Bonus Time
        
        //this could give matching bonus points
        //if he user matches the card
        //before a certain amount of the time passes during which the card is face up
        
        //can be zero which means "no bonus available" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        //how long this card has ever been faceup
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        
        //the last time this card was turned face up (and is still face up)
        var lastFaceUpDate: Date?
        // the accumulated time this card has been face up in the past
        //(i.e. not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0
        
        //how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        //percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        //whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        
        //whether we are currently face up, unmatched and have not yet used up the bonus window
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        //called when the card transitions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        //called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }
    }
}

