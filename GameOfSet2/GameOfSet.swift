//
//  GameOfSet.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

import Foundation

struct GameOfSet {
    
    private(set) var deck = DeckOfCards().allCards
    private(set) var cardsInPlay = [Card]()
    private(set) var setState: Bool?
    private(set) var score = 0
    var cardsLeft: Int { get { return deck.count } }
    var selectedCardsCount: Int { get { return selectedCards.count} }
    
    private(set) var selectedCards = [Card]() {
        didSet {
            if let setState = isSet() {
                for eachCard in selectedCards {
                    cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = setState ? Card.matchState.goodMatch : Card.matchState.badMatch
                }
            }
        }
    }
    
    mutating func dealCard(forCount: Int) {
        var dealCount: Int
        let setState = isSet()
        if forCount != 3 && setState == true {
            dealCount = 3
        } else {
            dealCount = forCount
        }
        
        for index in stride(from: dealCount - 1, through: 0, by: -1) {
            if deck.count > 0 {
                let removedCard = deck.remove(at: deck.count.arc4random)
                if setState == true {
                    cardsInPlay[cardsInPlay.index(of: selectedCards[index])!] = removedCard
                    selectedCards.removeLast()
                } else {
                    cardsInPlay.append(removedCard)
                }
            } else if setState == true {
                cardsInPlay.remove(at: cardsInPlay.index(of: selectedCards[index])!)
                selectedCards.removeLast()
            }
        }
    }
    
    mutating func changeSelection(touchedCard: Card) -> [Card] {
        if let setState = isSet() {
            let isNewCard = !selectedCards.contains(where: { $0 == touchedCard })
            if setState && isNewCard {
                dealCard(forCount: 3)
                //return cardsInPlay
            } else if !setState && isNewCard {
                for eachCard in selectedCards {
                    cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = .unselected
                }
                selectedCards.removeAll()
            }
        }
        
        if let indexOfTouchedCard = cardsInPlay.index(of: touchedCard) {
            
            if touchedCard.cardMatchState == .selectedUnmatched {
                if let indexOfSelectedCard = selectedCards.index(of: touchedCard) {
                    selectedCards.remove(at: indexOfSelectedCard)
                    cardsInPlay[indexOfTouchedCard].cardMatchState = .unselected
                }
            } else if touchedCard.cardMatchState == .unselected {
                selectedCards.append(touchedCard)
                if let setState = isSet() {
                    cardsInPlay[indexOfTouchedCard].cardMatchState = setState ? .goodMatch : .badMatch
                    score += setState ? 5 : -5
                } else {
                    cardsInPlay[indexOfTouchedCard].cardMatchState = .selectedUnmatched
                }
            }
        } else {
            print("I couldn't find the card to select")
        }
        return cardsInPlay
    }
    
    mutating func shuffleCards() {
        // Shuffle the cards
        var last = cardsInPlay.count - 1
        while(last > 0)
        {
            cardsInPlay.swapAt(last, last.arc4random)
            last -= 1
        }
    }
    
    func isSet() -> Bool? {
        if selectedCardsCount == 3 {
            var symbols = [Card.CardSymbols]()
            var numbers = [Int]()
            var colors = [Card.ColorOfSymbols]()
            var shading = [Card.ShadingOfSymbols]()
            
            for card in selectedCards {
                symbols.append(card.cardSymbols)
                numbers.append(card.numberOfSymbols)
                colors.append(card.colorOfSymbols)
                shading.append(card.shadingofSymbols)
            }
            
            if symbols.twoOfThree() {
                return false
            } else if numbers.twoOfThree() {
                return false
            } else if colors.twoOfThree() {
                return false
            } else if shading.twoOfThree() {
                return false
            }
            return true
        }
        return nil
    }
}

extension Array where Element : Hashable {
    func twoOfThree() -> Bool {
        return Set(self).count == 2
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
