//
//  GameOfSet.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//
// GameOfSet is the model representing the game logic.  There should be only one model per game
//

import Foundation

struct GameOfSet {
    
    private(set) var deck = DeckOfCards().allCards
    private(set) var cardsInPlay = [Card]() // represents all cards that are playable by the user
    private(set) var gameSetState = false // flag used to track if a set was previously detected while user selects the 4th card
    private(set) var score = 0
    var cardsLeft: Int { get { return deck.count } }
    var cardsInPlayCount: Int { get { return cardsInPlay.count} }
    var okToDeal = false // determines whether conditions are met to start dealing cards
    
    private(set) var selectedCards = [Card]() {
        didSet {
                
            if selectedCards.count > 0 { // there is at least one card selected
                
                // list of cards that are selected but a bad match.
                // this will always contain 0 or 3 cards since cards can only be marked as a bad match if there are 3 of them.
                let unmatchedCards = cardsInPlay.filter( { $0.cardMatchState == Card.matchState.badMatch} )
                
                if unmatchedCards.count > 0 { // unselect all of the bad match cards
                    for eachCard in unmatchedCards {
                        cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = Card.matchState.unselected
                    }
                }
                
                if let setState = isSet() { // true only if there are three cards selected.
                    
                    // update the card selection to relfect whether the cards are a set or not.
                    for eachCard in selectedCards {
                        cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = setState ? Card.matchState.goodMatch : Card.matchState.badMatch
                    }
                    selectedCards.removeAll() // empties selected cards list since they are all marked as good or bad match
                    // keep track that there is a currently marked group of cards that are good or bad match.
                    // this is needed since selected cards is now empty so we can't rely on isSet to knoiw that there is a group of three cards taht are a good or bad match
                    gameSetState = setState
                    score += setState ? 5 : -5 // update the score based on valid or invalid set
                }
            }
        }
    }
    
    // deals number of cards as specified in forCount
    mutating func deal(forCount: Int) {
        if cardsLeft >= 3 { // there are still at least 3 cards in the deck, so 3 new cards can be drawn
            for _ in 0..<forCount {
                let drawnCard = deck.remove(at: deck.count.arc4random) // draw card from the deck
                cardsInPlay.append(drawnCard)
            }
        }
        okToDeal = false
        gameSetState = false
        
    }
    
    mutating func removeFromCardsInPlay() {
        cardsInPlay = cardsInPlay.filter( {$0.cardMatchState != Card.matchState.goodMatch } )
        gameSetState = false
    }
    
    // return the index of a Card within the cardsInPlay
    func getCardIndex(thisCard: Card) -> Int {
        
        return cardsInPlay.index(of: thisCard)!
    }
    
    // receives a Card, checks for set, then changes selection states based on the outcome
    mutating func changeSelection(indexOfTouchedCard: Int) -> Bool {
        
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
                selectedCards = selectedCards.filter( { $0 != cardsInPlay[indexOfTouchedCard] } ) // remove the card from selected
                cardsInPlay[indexOfTouchedCard].cardMatchState = .unselected // change card property to unselected
            
            case .unselected:
                cardsInPlay[indexOfTouchedCard].cardMatchState = .selectedUnmatched // select the card
                
                // check if a set was determined before the current card was selected.  if so, it's time to deal
                okToDeal = gameSetState
                selectedCards.append(cardsInPlay[indexOfTouchedCard]) // add card to selected cards
            
            default:
                break
        }
        return okToDeal // indicate whether conditions are rigyt to deal
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
            
            // create a list for each attribute of the card so they can be compared
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
