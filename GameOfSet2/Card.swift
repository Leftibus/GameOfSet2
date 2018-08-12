//
//  Card.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

import Foundation

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
    
    
    enum matchState {
        case unselected
        case selectedUnmatched
        case goodMatch
        case badMatch
    }
    
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
        self.identifier = Card.getUniqueIdentifier()
        self.cardMatchState = .unselected
        self.numberOfSymbols = symbolCount
        self.cardSymbols = symbolType
        self.shadingofSymbols = symbolShading
        self.colorOfSymbols = symbolColor
    }
    
}
