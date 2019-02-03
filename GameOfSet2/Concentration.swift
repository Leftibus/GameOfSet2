//
//  Concentration.swift
//  Concentration
//
//  Created by Kevin Wojtas on 1/21/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

import Foundation

struct Concentration
{
    private(set) var cards = [ConcentrationCard]()
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            
            return cards.indices.filter{ cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    mutating func chooseCard(at index: Int)
    {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chose  index not in the cards")
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                cards[index].isFaceUp = true
                
            } else {
                indexOfOneAndOnlyFaceUpCard = index

            }
        }
    }
    
    init(numberOfPairsOfCards: Int)
    {
        assert(numberOfPairsOfCards > 0, "Concentration.init(\(numberOfPairsOfCards)): you must have at least one pair of cards")
        for _ in 0..<numberOfPairsOfCards
        {
            let card = ConcentrationCard()
            cards += [card, card]
        }
        
        // Shuffle the cards
        var last = cards.count - 1
        while(last > 0)
        {
            cards.swapAt(last, last.arc4random)
            last -= 1
        }
        
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
