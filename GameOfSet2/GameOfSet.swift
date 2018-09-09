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
    var cardsInPlayCount: Int { get { return cardsInPlay.count} }
    
    private(set) var selectedCards = [Card]() {
        didSet {
            if let setState = isSet() {
                for eachCard in selectedCards {
                    cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = setState ? Card.matchState.goodMatch : Card.matchState.badMatch
                }
            }
        }
    }
    
    // deals number of cards as specified in forCount
    mutating func dealCard(forCount: Int) {
        var dealCount: Int
        let setState = isSet() // setState is true if there is a set, false if there is a not a set, and null if not enough cards selected.
        if forCount != 3 && setState == true {
            dealCount = 3
        } else {
            dealCount = forCount
        }
        
        for index in stride(from: dealCount - 1, through: 0, by: -1) {
            if cardsLeft > 0 { // there are still cards in the deck, so 3 new cards can be drawn
                let removedCard = deck.remove(at: deck.count.arc4random) // draw card from the deck
                if setState == true { // there is a valid set, so replace the old card with drawn card
                    cardsInPlay[cardsInPlay.index(of: selectedCards[index])!] = removedCard
                    selectedCards.removeLast()
                } else { // there is not a valid set, so add drawn card to cards in play
                    cardsInPlay.append(removedCard)
                }
            } else if setState == true { //there are no cards left to draw, but there is a set
                cardsInPlay.remove(at: cardsInPlay.index(of: selectedCards[index])!) //remove cards in play
                selectedCards.removeLast() // empyt the list of selected cards
            }
        }
    }
    
    // receives a Card, checks for set, then changes selection states based on the outcome
    mutating func changeSelection(touchedCard: Card) {
        if let setState = isSet() { // three cards are selected, but may or may not be a set
            let isNewCard = !selectedCards.contains(where: { $0 == touchedCard }) // sets isNewCard to True if the card was not one of the currenlty selected cards
            if setState && isNewCard { //  there is a valid set and a new card was touched
                dealCard(forCount: 3)
            } else if !setState && isNewCard { // not a valid set and a new card was touched
                for eachCard in selectedCards {
                    cardsInPlay[cardsInPlay.index(of: eachCard)!].cardMatchState = .unselected
                } // deselect all the selected cards.
                selectedCards.removeAll()
            }
            // if an aleady existing card was touched when three cards are already selected, do nothing
        }
        
        // there are not three cards selected, so invert the selection status of the touched card
        if let indexOfTouchedCard = cardsInPlay.index(of: touchedCard) { // get the index of the touched card
            
            if touchedCard.cardMatchState == .selectedUnmatched { // cards is already selected, but not matched
                if let indexOfSelectedCard = selectedCards.index(of: touchedCard) {
                    selectedCards.remove(at: indexOfSelectedCard) // remove from selected card list
                    cardsInPlay[indexOfTouchedCard].cardMatchState = .unselected // change card to unselected
                }
            } else if touchedCard.cardMatchState == .unselected { // card is not selected
                selectedCards.append(touchedCard) // add card to selected cards
                if let setState = isSet() { // check for set in case there are 3 selected cards now
                    cardsInPlay[indexOfTouchedCard].cardMatchState = setState ? .goodMatch : .badMatch // change the match state to good or bad
                    score += setState ? 5 : -5 // update the score based on valid or invalid set
                } else {
                    cardsInPlay[indexOfTouchedCard].cardMatchState = .selectedUnmatched
                }
            }
        } else {
            print("I couldn't find the card to select")
        }
//        return cardsInPlay // returns ALL the cards in play, which includes all of the card changes made above
        // TODO: consider returning only the cards that changed
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
