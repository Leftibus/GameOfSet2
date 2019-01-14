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
    private(set) var matchedCards = [Card]()
    private(set) var gameSetState = false
    private(set) var score = 0
    var cardsLeft: Int { get { return deck.count } }
    var cardsInPlayCount: Int { get { return cardsInPlay.count} }
    var gameDealType = dealType.deal
    
    private(set) var selectedCards = [Card]() {
        didSet {
                
            if selectedCards.count > 0 {
                
                let unmatchedCards = cardsInPlay.filter( { $0.cardMatchState == Card.matchState.badMatch} )
                
                if unmatchedCards.count > 0 {
                    for eachCard in unmatchedCards {
                        cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = Card.matchState.unselected
                    }
                }
                
                if let setState = isSet() { // setState is true if there is a set, false if there is a not a set, and null if not enough cards selected.
                    for eachCard in selectedCards {
                        cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = setState ? Card.matchState.goodMatch : Card.matchState.badMatch
                    }
                    selectedCards.removeAll()
                    gameSetState = setState
                    score += setState ? 5 : -5 // update the score based on valid or invalid set
                }
            }
        }
    }
    
    enum dealType {
        case hold
        case deal
        case replace
        case discard
    }
    
    // deals number of cards as specified in forCount
    mutating func deal(forCount: Int) {
        if cardsLeft > 0 { // there are still cards in the deck, so 3 new cards can be drawn
            for _ in 0..<forCount {
                let drawnCard = deck.remove(at: deck.count.arc4random) // draw card from the deck
                cardsInPlay.append(drawnCard)
            }
        }
        gameDealType = .hold
        gameSetState = false
        
    }
    
    mutating func removeFromCardsInPlay() {
        cardsInPlay = cardsInPlay.filter( {$0.cardMatchState != Card.matchState.goodMatch } )
        gameSetState = false
    }
    
    func getCardIndex(thisCard: Card) -> Int {
        
        return cardsInPlay.index(of: thisCard)!
    }
    
    // receives a Card, checks for set, then changes selection states based on the outcome
    mutating func changeSelection(indexOfTouchedCard: Int) -> dealType {
        
        // update gameState if three cards are already selected and new card is touched
        if let setState = isSet() { // three cards are selected, but may or may not be a set
            let isNewCard = !selectedCards.contains(where: { $0 == cardsInPlay[indexOfTouchedCard] }) // sets isNewCard to True if the card was not one of the currenlty selected cards
            if !setState && isNewCard { // not a valid set and a new card was touched
                for eachCard in selectedCards {
                    cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = .unselected
                } // deselect all the selected cards.
            }
            
            selectedCards.removeAll()
        }
        
        // invert the selection status of the touched card
        
        switch cardsInPlay[indexOfTouchedCard].cardMatchState {
            case .selectedUnmatched:
                selectedCards = selectedCards.filter( { $0 != cardsInPlay[indexOfTouchedCard] } )
                cardsInPlay[indexOfTouchedCard].cardMatchState = .unselected
            
            case .unselected:
                cardsInPlay[indexOfTouchedCard].cardMatchState = .selectedUnmatched
                
                if gameSetState {
                    gameDealType = .deal
                } else {
                    gameDealType = .hold
                }
                
                selectedCards.append(cardsInPlay[indexOfTouchedCard])
            
            default:
                break
        }
        
        return gameDealType
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
    
    // checks for set and returns one of three values depending on the number of cards currently selected
    // if 3 cards are not selected, return nil
    // if 3 cards are selected return true if it is a valid set
    // if 3 cards are selected return false if it is an invalid set.
    func isSet() -> Bool? {
        
        if selectedCards.count == 3 {
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
            
            // checks each array of the card subtypes
            // if two out of the three subtypes match, then it is a "bad match"
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
    
    // when this function is called, there will be three elements in the array
    // function checks if two out of the three elements are a match
    // this is done by converting the array into a Set which removes any duplicates
    // if there are no duplicates (all different) count of elements in set is 3
    // if all three elements match (all same), count oif elements in set is 1
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
