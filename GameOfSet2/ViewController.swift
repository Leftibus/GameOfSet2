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
    
    @IBOutlet weak var SetCardView: SetCardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealOnSwipe))
            swipe.direction = [.up, .down]
            SetCardView.addGestureRecognizer(swipe)
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleOnRotateGesture))
            SetCardView.addGestureRecognizer(rotate)
        }
    }
    
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
        print("Screen native scale: \(UIScreen.main.nativeScale); native bounds area: \(UIScreen.main.nativeBounds.area)")
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

