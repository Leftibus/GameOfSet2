//
//  DeckOfCards.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

// DeckOfCards holds the complete deck of cards.  There should be one deck of cards per game.

import Foundation

struct DeckOfCards {
    
    var allCards = [Card]()
    
    // loops through all options of symbols, count, shading and color to create the deck
    init() {
        for numberOfSymbols in 1...3 {
            
            for symbol in Card.CardSymbols.all {
                
                for shading in Card.ShadingOfSymbols.all {
                    
                    for color in Card.ColorOfSymbols.all {
                        
                        allCards.append(Card(symbolCount: numberOfSymbols, symbolType: symbol, symbolShading: shading, symbolColor: color))
                    }
                }
            }
        }
    }
}
