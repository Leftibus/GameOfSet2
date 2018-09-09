//
//  ViewController.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var game = GameOfSet()
    private var cardViewList = [SetCardView]()
    
    private var textSize: CGFloat {
        get { return self.textSize }
        set {
            scoreLabel.font = scoreLabel.font.withSize(newValue)
            cardsLeftLabel.font = cardsLeftLabel.font.withSize(newValue)
            newGameButtonLabel.titleLabel?.font = newGameButtonLabel.titleLabel?.font.withSize(newValue)
        }
    }
    
    @IBOutlet weak var CardPlayArea: UIView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealOnSwipe))
            swipe.direction = [.up, .down]
            CardPlayArea.addGestureRecognizer(swipe)
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleOnRotateGesture))
            CardPlayArea.addGestureRecognizer(rotate)
        }
    }
    
    lazy var cardPlayAreaBounds = CardPlayArea.bounds
    lazy var grid = Grid(layout: Grid.Layout.aspectRatio(4/7), frame: cardPlayAreaBounds)
    
    @IBOutlet weak var newGameButtonLabel: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cardsLeftLabel: UILabel!
    
    @IBAction func newGameButton(_ sender: UIButton) {
        startNewGame()
    }
    
    override func viewDidLayoutSubviews() {
        grid.frame = CGRect(origin: cardPlayAreaBounds.origin, size: CardPlayArea.frame.size)
        updateViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidth = UIScreen.main.nativeBounds.width
        if screenWidth > 1242 {
            textSize = 24.0
        } else if screenWidth > 750 {
            textSize = 17.0
        } else {
            textSize = 14.0
        }
        startNewGame()
    }
    
    func startNewGame() {
        let startingCardCount = 12
        game = GameOfSet()
        grid.cellCount = startingCardCount
        dealCards(forCount: startingCardCount)
    }
    
    func updateViews() {

        while cardViewList.count != game.cardsInPlayCount {
            if cardViewList.count < game.cardsInPlayCount {
                let newCardView = SetCardView(frame: CGRect.zero)
                CardPlayArea.addSubview(newCardView)
                newCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeCardSelection(_ :))))
                CardPlayArea.bringSubview(toFront: newCardView)
                cardViewList.append(newCardView)
            } else {
                if let lastCardView = cardViewList.last {
                    lastCardView.removeFromSuperview()
                    cardViewList.removeLast()
                }
            }
        }
        
        for index in 0..<game.cardsInPlayCount {
            cardViewList[index].setCard(frame: grid[index]!, card: game.cardsInPlay[index])
        }
        
        scoreLabel.text = "Score: \(game.score)"
        cardsLeftLabel.text = "Cards Left: \(game.cardsLeft)"
    }
    
    func dealCards(forCount: Int) {
        game.dealCard(forCount: forCount)
        grid.cellCount = game.cardsInPlayCount
        updateViews()
    }
    
    @objc func dealOnSwipe() {
        dealCards(forCount: 3)
    }
    
    @objc func shuffleOnRotateGesture() {
        game.shuffleCards()
        updateViews()
    }
    
    @objc func changeCardSelection(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
            case .ended:
                if let touchedCard = recognizer.view as? SetCardView {
                    if let index = cardViewList.index(of: touchedCard) {
                        game.changeSelection(touchedCard: game.cardsInPlay[index])
                    } else {
                        print("I couldn't find the card to select")
                    }
                    
                    updateViews()
                }
            default: break
        }
    }

}

private extension CGRect {
    var area: CGFloat {
        return width * height
    }
}

