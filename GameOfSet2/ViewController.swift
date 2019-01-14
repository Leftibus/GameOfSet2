//
//  ViewController.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//
//  controls the view of the Game of Set
//  The game will start with an empty play area, without any cards
//  Once the user taps "New Game", 12 cards will be dealt to start
//

import UIKit

class ViewController: UIViewController {

    private var game = GameOfSet() // initialize instance of model which contains game logic
    private var cardViewList = [SetCardView]() // initialize array of views that represents the views shown on screen
    private var observer: NSKeyValueObservation?
    private var discardTimer: Timer?
    
    lazy var discardAnimator = UIDynamicAnimator(referenceView: view)
    
    lazy var discardBehavior = DiscardBehavior(in: discardAnimator)
    
    @IBOutlet weak var CardPlayArea: UIView! // view that represents all of the cards in play
    
    lazy var cardPlayAreaBounds = CardPlayArea.bounds
    // subdivides the play area into frames
    lazy var grid = Grid(layout: Grid.Layout.aspectRatio(SizeConst.aspectRatio), frame: cardPlayAreaBounds)
    
    @IBOutlet weak var newGameButtonLabel: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dealCardsButton: UIButton!
    
    
    @IBAction func newGameButton(_ sender: UIButton) {
        // new game button triggers start of new game.
        startNewGame()
    }
    
    @IBAction func dealCardsButton(_ sender: UIButton) {
        dealCards()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // cleanup observer when view is about to disappear
        observer?.invalidate()
    }
    
    // sets up the game when first loaded
    // no cards are dealt at the beginning.  User needs to tap "New Game" to begin
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adjusts textsize to compensate for the device screen width
        let fontSize = scaledFontSize
        scoreLabel.font = scoreLabel.font.withSize(fontSize)
        newGameButtonLabel.titleLabel?.font = newGameButtonLabel.titleLabel?.font.withSize(fontSize)
        dealCardsButton.titleLabel?.font = dealCardsButton.titleLabel?.font.withSize(fontSize)
        
        scoreLabel.layer.borderWidth = SizeConst.labelBorderWidth
        scoreLabel.layer.borderColor = UIColor.black.cgColor
        dealCardsButton.isEnabled = false
        dealCardsButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        
        // set observer to watch the bounds of the CardPlayArea, so that if the bounds change when device is rotated
        // then the screen layout is reset, including grid and views.
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
        game = GameOfSet()
        dealCards(forCount: CardCount.start)
    }
    
    func updateViews() {
        
        // function is called each time a change to the cards needs to be made, including size, border, location of cards
        
        for index in 0..<cardViewList.count {
            
            // change(set) the position and card data of each view on cardViewList
            cardViewList[index].setCard(frame: grid[index]!, card: game.cardsInPlay[index])
        }
    
        scoreLabel.text = "Score: \(game.score)" // update the score displayed on the screen based on game score property
    }
    
    // called when cards need to be added and/or when cards to be removed from the play area after a match is found
    @objc func dealCards(forCount: Int = CardCount.deal) {
        
        // identify cards to be discarded
        
        let discardList = game.cardsInPlay.filter( { $0.cardMatchState == Card.matchState.goodMatch } )
        
        // since deal cards could be called without any cards to be discarded, only run the following code if discards were identified
        if discardList.count != 0 {
            var discardViewList = [SetCardView]()
            for card in discardList {
                let index = game.getCardIndex(thisCard: card)
                discardViewList.append(cardViewList[index])
            }
            game.removeFromCardsInPlay() // removes the cards from the model's list of cards in play
            animateDiscard(cardsToDiscardViewList: discardViewList) // start the discard animation based on the discardList
        }
        
        // deal cards only if there are cards left in the deck from the model
        if game.cardsLeft > 0 {
            game.deal(forCount: forCount) // get forCount number of card type instances. There will now be more cards in the model than there are views on the screen
            
            var animationDelay = 0.0 // starts at 0, then incremented for each card so that cards are dealt one by one, instead of all at once
            let nextNewCardIndex = cardViewList.count // index of the next card to be dealt
            let lastNewCardIndex = nextNewCardIndex + forCount // index of the last card to be dealt
            grid.cellCount = game.cardsInPlayCount // changes the grid to account for extra cards that are now in the model
            
            let buttonFrame = dealCardsButton.convert(dealCardsButton.frame, to: CardPlayArea)
            let startingFrame = CGRect(origin: buttonFrame.origin, size: CGSize(width: buttonFrame.height, height: buttonFrame.width))
            
            for index in nextNewCardIndex..<lastNewCardIndex {
                
                let newCardView = SetCardView(startFrame: startingFrame, targetFrame: grid[index]!, showDelay: animationDelay)
                newCardView.center = buttonFrame.center
                
                CardPlayArea.addSubview(newCardView) // add new card view to the superview (cardPlay Area)
                cardViewList.append(newCardView) // add the new card to the list of views shown on the screen
                
                newCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeCardSelection(_ :))))
                
                animationDelay += TimeConst.dealDelay
            }
        }
        
        updateViews()
        dealCardsButton.isEnabled = game.cardsLeft > 0 // disable deal button if there aren't any cards left
        dealCardsButton.backgroundColor = dealCardsButton.isEnabled ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) // grey out the deal button if no cards left
    }
    
    func animateDiscard(cardsToDiscardViewList: [SetCardView]) {
        
        // bring each discard view to the front so user can see the bounce then start the bounce animation for each card view
    
        for cardView in cardsToDiscardViewList {
            
            CardPlayArea.bringSubviewToFront(cardView)
            discardBehavior.addItem(cardView)
        }
        
        let selector = #selector(sendToDiscardPile(timer:))
        // timer is used to delay the aniimation which sends the view to discard pile.
        discardTimer = Timer.scheduledTimer(timeInterval: TimeConst.bounceDuration, target: self, selector: selector, userInfo: cardsToDiscardViewList, repeats: false)
        cardViewList = cardViewList.filter({$0.borderColor != UIColor.green}) // remove the matched views from the list of displayed views
        grid.cellCount = cardViewList.count // change the grid to reflect that there are now fewer card views to be displayed
        updateViews()
}
    
    // once the card views have bounced around, start the animation to do the final discard
    @objc func sendToDiscardPile(timer: Timer){
        
        let discardPileFrame = scoreLabel.convert(dealCardsButton.frame, to: CardPlayArea)
        
        guard let discardedViews = timer.userInfo as? [SetCardView] else { return } // timer.userInfo is used to pass the list of views to be discarded
        
        // add animation to each card view to be discarded
        for cardView in discardedViews {
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: TimeConst.discardDuration,
                delay: 0.0,
                options: [.layoutSubviews],
                animations: {
                    // animate the movement and resize of the cardView to match the discard pile
                    self.discardBehavior.removeItem(cardView)
                    cardView.transform = CGAffineTransform(rotationAngle: self.quarterTurn)
                    cardView.frame = discardPileFrame
            },
                // flip the card over once it reaches the discard pile
                completion: { if $0 == .end {
                    UIView.transition(with: cardView,
                                      duration: TimeConst.discardDuration,
                                      options: [.transitionFlipFromLeft],
                                      animations: { cardView.isFaceUp = false
                                        cardView.updateCard()
                    },
                                      completion: {_ in cardView.removeFromSuperview() } )
                    }}
            )
        }
        timer.invalidate() // cancel the timer now that the discard animations have been launched
    }
    
    // handles user touch of a card view
    @objc func changeCardSelection(_ recognizer: UITapGestureRecognizer) {
        
        switch recognizer.state {
            case .ended: // user completed the touch of the card view
                if let touchedCard = recognizer.view as? SetCardView { // identifies which card bview was touched
                    if let index = cardViewList.index(of: touchedCard) { // get the index of the touhced card in the cardview list
                    
                        if game.changeSelection(indexOfTouchedCard: index) == .deal { // model indicates that it is time to deal cards
                            dealCards()
                        } else { // no cards need to be dealt, but the views need to be updated based on any changes to selection status
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

// ViewController Constants
extension ViewController {
    
    // number of cards to deal
    private struct CardCount {
        
        static let start = 12 // cards to deal when new game starts
        static let deal = 3 // cards to deal for rest of game (after deal button, after match found)
    }
    
    // Sizes
    private struct SizeConst {
        
        static let aspectRatio: CGFloat = 4 / 7 // used for grid that contains each card in the playing area
        static let labelBorderWidth: CGFloat = 1.0 // score label border width
    }
    
    // Animation Timing Constants
    private struct TimeConst {
        
        static let dealDelay = 0.2  // animation delay between the deal of each card
        static let flipDuration = 1.0  // Duration of flip card animation
        static let discardDuration = 0.6  // duration of animation to send card to deck
        static let bounceDuration = 2.0  // duration of card bounce after a match
    }
    
    // property that reflects the textSize to be used based on the device/screen size being used
    private var scaledFontSize: CGFloat {
        
        switch UIScreen.main.nativeBounds.width {
        case 0..<750: // small screen such as iPhone 7+ and earlier
            return 14.0
        case 750...1242: // medium size screen such as iPhone 8 to iPhone XS Max
            return 17.0
        default: // large screen size - ipads
            return 24.0
        }
    }
    
    private var quarterTurn: CGFloat {
        return 0.5 * CGFloat.pi // quarter turn is 1/4 of 2 * pi
    }
}

// extends CGRect to add property for the center coordinates of the rectangle
private extension CGRect {

    var center: CGPoint {
        return CGPoint(x: origin.x + width/2, y: origin.y + height/2)
    }
}

// extends CGFloat to provide a simpler means of generating a random number between 0 and the receiver
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

