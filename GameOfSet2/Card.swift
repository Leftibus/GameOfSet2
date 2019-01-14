//
//  Card.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//
// Card type holds data to describe tha card per the rules of Set
//  - Number of Symbols
//  - Shape of Symbol
//  - Color of Symbol
//  - Shading of Symbol
//
//  Card conforms to Hashable and Equatable protocols so that the cards can be 

import Foundation


// TODO: Does Card really need to conform to Hashable?  GameOfSet only checks equality of properties which are Int and Enums
struct Card: Hashable {
    
    private (set) var identifier: Int
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var cardMatchState: matchState
    
    private (set) var numberOfSymbols: Int
    private (set) var cardSymbols: CardSymbols
    private (set) var shadingofSymbols: ShadingOfSymbols
    private (set) var colorOfSymbols: ColorOfSymbols
    
    // indicates whether the selection status of card, if unmatched and match status if card is one of three selected cards
    enum matchState {
        case unselected
        case selectedUnmatched
        case goodMatch
        case badMatch
    }
    
    // shape of symbol that will be displayed on the card
    enum CardSymbols {
        case oval
        case squiggle
        case diamond
        
        static var all = [CardSymbols.oval, .squiggle, .diamond]
    }
    enum ShadingOfSymbols {
        case open
        case striped
        case closed
        
        static var all = [ShadingOfSymbols.open, .striped, .closed]
    }
    
    enum ColorOfSymbols {
        case red
        case green
        case purple
        
        static var all = [ColorOfSymbols.red, .green, .purple]
    }
    
    private static var indentifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        indentifierFactory += 1
        return indentifierFactory
    }
    
    init(symbolCount: Int, symbolType: Card.CardSymbols, symbolShading: Card.ShadingOfSymbols, symbolColor: Card.ColorOfSymbols) {
        
        self.numberOfSymbols = symbolCount
        self.cardSymbols = symbolType
        self.shadingofSymbols = symbolShading
        self.colorOfSymbols = symbolColor
        
        self.identifier = Card.getUniqueIdentifier() // supportsd making the card hashable
        self.cardMatchState = .unselected
    }
    
}
