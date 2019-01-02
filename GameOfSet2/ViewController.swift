//
//  ViewController.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var game = GameOfSet() // initialize instance of model which contains game logic
    private var cardViewList = [SetCardView]() // initialize array of views that represents the views shown on screen
    private var observer: NSKeyValueObservation?
    private var discardTimer: Timer?
    
    lazy var discardAnimator = UIDynamicAnimator(referenceView: view)
    
    lazy var discardBehavior = DiscardBehavior(in: discardAnimator)
    
    // property that reflects the textSize to be used based on the device/screen size being used
    private var textSize: CGFloat = 14.0 {
        
        willSet { //  using willSet since we don't need a getter.
            // updates the textsize of all labels in case the screen size changes
            scoreLabel.font = scoreLabel.font.withSize(newValue)
            newGameButtonLabel.titleLabel?.font = newGameButtonLabel.titleLabel?.font.withSize(newValue)
            dealCardsButton.titleLabel?.font = dealCardsButton.titleLabel?.font.withSize(newValue)
        }
    }
    
    @IBOutlet weak var CardPlayArea: UIView! // view that represents all of the cards in play
    
    lazy var cardPlayAreaBounds = CardPlayArea.bounds
    lazy var grid = Grid(layout: Grid.Layout.aspectRatio(4/7), frame: cardPlayAreaBounds)  // subdivides the play area into frames
    
    @IBOutlet weak var newGameButtonLabel: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealCardsButton: UIButton!
    
    
    @IBAction func newGameButton(_ sender: UIButton) {
        // new game button truggers start of new game.
        startNewGame()
    }
    
    @IBAction func dealCardsButton(_ sender: UIButton) {
        dealCards()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        observer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: group and move "magic numbers" to end of code
        // checks the screen width of the device and adjusts textsize to compensate
        let screenWidth = UIScreen.main.nativeBounds.width
        if screenWidth > 1242 {
            self.textSize = 24.0
        } else if screenWidth > 750 {
            self.textSize = 17.0
        } else {
            self.textSize = 14.0
        }
        
        scoreLabel.layer.borderWidth = 1
        scoreLabel.layer.borderColor = UIColor.black.cgColor
        dealCardsButton.isEnabled = false
        dealCardsButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        
        // set observer to watch the bounds of the CardPlayArea, so that if the bounds change when device is rotated
        // then the screen layour is reset, including grid and views.
        observer = CardPlayArea.layer.observe(\.bounds) { object, _ in
            self.grid.cellCount = self.game.cardsInPlayCount
            self.grid.frame = object.bounds
            self.updateViews()
        }
    }
    
    func startNewGame() {

        CardPlayArea.subviews.forEach { $0.removeFromSuperview() }
        cardViewList.removeAll()
        dealCardsButton.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        let startingCardCount = 12
        game = GameOfSet()
        dealCards(forCount: startingCardCount)
    }
    
    func updateViews() {
        
        // create a var that is a filtered list of cardViewList where cardViewList[].currentCard.cardMatchState = .goodMatch
        // loop through the filtered list and discard each one
        // will need to move the discard animation code to a new function
        
        for index in 0..<cardViewList.count {
            
            // change(set) the position and card data of the each view on cardViewList
            cardViewList[index].setCard(frame: grid[index]!, card: game.cardsInPlay[index])
        }
    
        scoreLabel.text = "Score: \(game.score)" // update the score displayed on the screen based on game score property
    }
    
    
    @objc func dealCards(forCount: Int = 3) {
        
        let discardList = game.cardsInPlay.filter( { $0.cardMatchState == Card.matchState.goodMatch } )
        
        if discardList.count != 0 {
            var discardViewList = [SetCardView]()
            for card in discardList {
                let index = game.getCardIndex(thisCard: card)
                discardViewList.append(cardViewList[index])
            }
            game.dicardFromCardsInPlay()
            animateDiscard(cardsToDiscardViewList: discardViewList)
        }
        
        if game.cardsLeft > 0 {
            game.deal(forCount: forCount) // get forCount number of card type instances
            
            var delayIndex = 0.0 // starts at 0, then incremented for each card so that cards are deat one by one, instead of all at once
            var cellIndex = cardViewList.count
            grid.cellCount = game.cardsInPlayCount
            
            cellIndex = cardViewList.count
            grid.cellCount = game.cardsInPlayCount
            
            for _ in 1...forCount {
                let buttonFrame = dealCardsButton.convert(dealCardsButton.frame, to: CardPlayArea)
                let startingFrame = CGRect(origin: buttonFrame.origin, size: CGSize(width: buttonFrame.height, height: buttonFrame.width))
                
                let newCardView = SetCardView(startFrame: startingFrame, endFrame: grid[cellIndex]!, showDelay: delayIndex * 0.2)
                newCardView.center = buttonFrame.center
                
                CardPlayArea.addSubview(newCardView) // add new card view to the superview, cardPlay Area
                cardViewList.append(newCardView) // add the new card to the list of views shown on the screen
                
                newCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeCardSelection(_ :))))
                
                delayIndex += 1
                cellIndex += 1
                
            }
        }
        
        updateViews()
        dealCardsButton.isEnabled = game.cardsLeft > 0
        dealCardsButton.backgroundColor = dealCardsButton.isEnabled ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    func animateDiscard(cardsToDiscardViewList: [SetCardView]) {
        
        for cardView in cardsToDiscardViewList {
            
            CardPlayArea.bringSubviewToFront(cardView)
            discardBehavior.addItem(cardView)
        }
        
        let selector = #selector(sendToDiscardPile(timer:))
        discardTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: selector, userInfo: cardsToDiscardViewList, repeats: false)
        cardViewList = cardViewList.filter({$0.borderColor != UIColor.green}) // remove the mathced views from the list of displayed views
        grid.cellCount = cardViewList.count
        updateViews()
}
    
    @objc func sendToDiscardPile(timer: Timer){
        let discardPileFrame = scoreLabel.convert(dealCardsButton.frame, to: CardPlayArea)
        
        guard let discardedViews = timer.userInfo as? [SetCardView] else { return }
        
        for cardView in discardedViews {
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: 0.0,
                options: [.layoutSubviews],
                animations: {
                    self.discardBehavior.removeItem(cardView)
                    cardView.transform = CGAffineTransform(rotationAngle: 0.5 * CGFloat.pi)
                    cardView.frame = discardPileFrame
            },
                completion: { if $0 == .end {
                    UIView.transition(with: cardView,
                                      duration: 1.0,
                                      options: [.transitionFlipFromLeft],
                                      animations: { cardView.isFaceUp = false
                                        cardView.updateCard()
                    },
                                      completion: {_ in cardView.removeFromSuperview() } )
                    }}
            )
        }
        timer.invalidate()
    }
    
    @objc func changeCardSelection(_ recognizer: UITapGestureRecognizer) {
        
        switch recognizer.state {
            case .ended:
                if let touchedCard = recognizer.view as? SetCardView {
                    if let index = cardViewList.index(of: touchedCard) {
                    
                        if game.changeSelection(indexOfTouchedCard: index) == .deal {
                            
                            dealCards()
                        } else {
                            updateViews()
                        }
                    } else {
                        print("I couldn't find the card to select")
                    }
                }
            default: break
        }
    }

}

private extension CGRect {
    var area: CGFloat {
        return width * height
    }
    var center: CGPoint {
        return CGPoint(x: origin.x + width/2, y: origin.y + height/2)
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

