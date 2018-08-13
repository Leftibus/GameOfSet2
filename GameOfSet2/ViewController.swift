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
    
    private var textSize: CGFloat {
        get { return self.textSize }
        set {
            scoreLabel.font = scoreLabel.font.withSize(newValue)
            cardsLeftLabel.font = cardsLeftLabel.font.withSize(newValue)
            newGameButtonLabel.titleLabel?.font = newGameButtonLabel.titleLabel?.font.withSize(newValue)
        }
    }
    
    @IBOutlet weak var SetCardView: SetCardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealOnSwipe))
            swipe.direction = [.up, .down]
            SetCardView.addGestureRecognizer(swipe)
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleOnRotateGesture))
            SetCardView.addGestureRecognizer(rotate)
        }
    }
    
    @IBOutlet weak var newGameButtonLabel: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var cardsLeftLabel: UILabel!
    
    @IBAction func newGameButton(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBAction func changeCardSelection(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            let location: CGPoint = sender.location(in: SetCardView)
            if let touchedCard = SetCardView.checkCardTouch(touchPoint: location) {
                SetCardView.changeCards(listOfCardstoDraw: game.changeSelection(touchedCard: touchedCard))
                updateViews()
            }
        default: break
        }
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
        game = GameOfSet()
        let startingCardCount = 12
        dealCards(forCount: startingCardCount)
    }
    
    func updateViews() {
        SetCardView.changeCards(listOfCardstoDraw: game.cardsInPlay)
        scoreLabel.text = "Score: \(game.score)"
        cardsLeftLabel.text = "Cards Left: \(game.cardsLeft)"
    }
    
    func dealCards(forCount: Int) {
        game.dealCard(forCount: forCount)
        updateViews()
    }
    
    @objc func dealOnSwipe() {
        dealCards(forCount: 3)
    }
    
    @objc func shuffleOnRotateGesture() {
        game.shuffleCards()
        updateViews()
    }

}

private extension CGRect {
    var area: CGFloat {
        return width * height
    }
}

