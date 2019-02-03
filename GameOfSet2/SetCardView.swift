//
//  SetCardView.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    var currentCard: Card? // reflects the card data that will be displayed by the view.  View will only have one card in its life
    private var useableCardBox = CGRect() // represents the rect that can be used for the shape, which is smaller than the grid rect provided
    private var okToDealIn = true // flags the view to be animated during the first draw cycle.
    private var cardFrame = CGRect() // property that reflects current designated frame of the card
    private var showDelay = Double() // time lag after instantiation of view before deal animation starts
    private var cardSizeScaleFactor = CGFloat()  // used to scale various aspects of the view depending on device rotation
    var isFaceUp = false
    private(set) var borderColor = UIColor()
    
    
    init(startFrame: CGRect, targetFrame: CGRect, showDelay: Double, card: Card? = nil) {
        currentCard = card
        super.init(frame: startFrame)
        self.transform = CGAffineTransform(rotationAngle: -quarterTurn) // view starts -90 deg rotation to line up with deck
        self.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0)
        self.cardFrame = targetFrame // location that the view will be animated to when it is instantiated
        self.showDelay = showDelay // time delay before the card animates on the screen so that cards dont all deal simultaneously
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        // draws the card view based on the currentcard data
        
        var fillColor = UIColor()
        let cardHolderView = superview?.frame
        
        // scale accounts for scaling when the device is landscape versus portrait and for the size of the card
        cardSizeScaleFactor = rect.width / (cardHolderView!.height > cardHolderView!.width ? cardHolderView!.width : cardHolderView!.height)
        
        // inset card so there is space between cards.
        useableCardBox = rect.insetBy(SizeRatio.spaceBetweenCards)
        let borderPath = UIBezierPath(roundedRect: useableCardBox, cornerRadius: cornerRadius) // creates a rounded card border
        
        if let cardToDraw = currentCard {

            // sets border color based upon the match state of the card
            if isFaceUp {
                fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) // face of card is white
                switch cardToDraw.cardMatchState {
                case .unselected:
                    borderColor = .white
                case .selectedUnmatched:
                    borderColor = .blue
                case .badMatch:
                    borderColor = .red
                case .goodMatch:
                    borderColor = .green
                }
            } else {
                fillColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1) // back of card is orange
                borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            }
            
            // get the current context so that the shapes can be overlaid on the card
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            // draw card face with rounded corners
            context.saveGState()
            borderPath.addClip()
            fillColor.setFill()
            borderPath.fill()
            
            //draw border based on cardMatchState
            borderColor.setStroke()
            borderPath.lineWidth = cardBorderWidth
            borderPath.stroke()
            
            context.restoreGState()
            
            if isFaceUp { drawCardShapes(area: useableCardBox) } // only draws the card shapes if the card is faceup
            
        }
        
        if okToDealIn {
            okToDealIn = false // deal in only applies to first draw cycle, so flag is false for rest of view lifecycle.
            
            // animation to deal the move the card from gthe deck location to the card play area.
            // after card reaches intended location in card play area, animation runs to flip card over
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Animation.dealSpeed,
                delay: showDelay,
                options: [.layoutSubviews],
                animations: {
                    self.transform = CGAffineTransform(rotationAngle: 2 * self.quarterTurn)
                    self.frame = self.cardFrame
            },
                completion: { if $0 == .end {
                    UIView.transition(with: self,
                                      duration: Animation.cardFlipSpeed,
                                      options: [.transitionFlipFromLeft],
                                      animations: { self.isFaceUp = true
                                                    self.updateCard()
                    },
                                      completion: nil)
                    }}
            )
             superview!.sendSubviewToBack(self)
        }
    }
    
    // draws the card shapes based on the properties in the associated card
    func drawCardShapes(area: CGRect) {
    
        let shapeCount = currentCard!.numberOfSymbols
        let shapeType = currentCard!.cardSymbols
        let shapeFillType = currentCard!.shadingofSymbols
        var shapeColor: UIColor
        var shapePath: UIBezierPath
        
        // set the color of the shapes
        switch currentCard!.colorOfSymbols {
        case .green:
            shapeColor = .green
        case .purple:
            shapeColor = .purple
        case .red:
            shapeColor = .red
        }
        
        let shapeDivider = useableCardBox.height / CGFloat(shapeCount + 1) // calculates the height of the center line for the shape
        // build shape path and bounds
        for shapeIndex in 1...shapeCount {
            
            let centerY = CGFloat(shapeIndex) * shapeDivider // sets the y based on standard height of divider and the shape number
            
            // create shapepath for unique shape
            switch shapeType {
            case .squiggle:
                shapePath = makeSquigglePath(with: centerY)
            case .diamond:
                shapePath = makeDiamondPath(with: centerY)
            case .oval:
                shapePath = makeOvalPath(with: centerY)
            }
            
            // draw shape and fill
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            context.saveGState()
            shapeColor.setStroke()
            shapePath.lineWidth = cardBorderWidth
            shapePath.addClip()
            
            switch shapeFillType {
            case .striped:
                fillStripes(shapeBounds: shapePath.bounds)
            case .closed:
                shapeColor.setFill()
                shapePath.fill()
            default:
                break
            }
            
            shapePath.stroke()
            context.restoreGState()
        }
    }
    
    func makeSquigglePath(with centerY: CGFloat) -> UIBezierPath {
        let shapePath = UIBezierPath()
        let transform = CGAffineTransform.identity
        
        shapePath.move(to: Squiggle.start)

        for curve in Squiggle.curvePoints {
            shapePath.addQuadCurve(to: curve.to, controlPoint: curve.controlPoint)
        }
        let sizeScaleFactor = shapeWidth / shapePath.bounds.width
        
        shapePath.apply(transform.scaledBy(x: sizeScaleFactor, y: sizeScaleFactor)) // scale the size of the shapepath to fit the card
        
        let currentCenter = shapePath.bounds.center
        let newCenter = CGPoint(x: useableCardBox.width.mid, y: centerY)
        let newX = newCenter.x - currentCenter.x + useableCardBox.origin.x
        let newY = newCenter.y - currentCenter.y + useableCardBox.origin.y
        
        shapePath.apply(transform.translatedBy(x: newX, y: newY)) // move the shape to the cente rof the useable card area
        
        return shapePath
    }
    
    func makeDiamondPath(with centerY: CGFloat) -> UIBezierPath {
        // use the cent
        
        let shapePath = UIBezierPath()

        let newCenter = useableCardBox.origin.add(CGPoint(x: useableCardBox.width.mid, y: centerY))
        
        shapePath.move(to: newCenter.add(CGPoint(x: -shapeWidth.mid, y: 0)))
        shapePath.addLine(to: newCenter.add(CGPoint(x: 0, y: -shapeHeight.mid)))
        shapePath.addLine(to: newCenter.add(CGPoint(x: shapeWidth.mid, y: 0)))
        shapePath.addLine(to: newCenter.add(CGPoint(x: 0, y: shapeHeight.mid)))
        shapePath.close()
        
        return shapePath
    }
    
    func makeOvalPath(with centerY: CGFloat) -> UIBezierPath {
        
        let newOrigin = useableCardBox.origin.add(CGPoint(x: shapeInset, y: centerY - shapeHeight.mid))
        let ovalRect = CGRect(x: newOrigin.x, y: newOrigin.y, width: shapeWidth, height: shapeHeight)
        
        return UIBezierPath(roundedRect: ovalRect, cornerRadius: cornerRadius)
    }
    
    func fillStripes(shapeBounds: CGRect) {
        let stripePath = UIBezierPath()
        for yPos in stride(from: CGFloat(shapeBounds.origin.y), through: shapeBounds.origin.y + shapeBounds.height, by: stripeSpaceWidth) {
            stripePath.move(to: CGPoint(x: shapeBounds.origin.x, y: yPos))
            stripePath.addLine(to: CGPoint(x: shapeBounds.origin.x + shapeBounds.size.width, y: yPos))
        }
        stripePath.lineWidth = stripeWidth
        stripePath.stroke()
    }
    
    // update views to reflect any changes
    func updateCard() {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    // set the card that is associated with the view and to update the view based on changes in the viewcontroller
    func setCard(frame: CGRect, card: Card){
        currentCard = card
        // check if the location and/or size have changed from current, if so animate to the new size/location
        if self.cardFrame != frame {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Animation.resizeSpeed,
                delay: 0.0,
                options: [.layoutSubviews],
                animations: { self.frame = frame },
                completion: nil )
            self.cardFrame = frame
        }
        superview!.sendSubviewToBack(self) // moves to the back layer so that anhy cards that are dealt or discarded will be on top
        updateCard()
    }
}

private extension CGFloat {
    
    var mid: CGFloat {
        return self / 2
    }
}

// create ability to combine two CGPoints
private extension CGPoint {
    func add(_ second: CGPoint) -> CGPoint {
        let newX = self.x + second.x
        let newY = self.y + second.y
        return CGPoint(x: newX, y: newY)
    }
}


private extension CGRect {
    
    var center: CGPoint {
        get {
            return CGPoint(x: origin.x + (width.mid), y: origin.y + (height.mid))
        }
        set {
            origin = CGPoint(x: center.x - (width.mid), y: center.y - (height.mid))
        }
    }
}

private extension CGRect {
    func insetBy(_ widthFactor: CGFloat) -> CGRect {
        let insetSpace = widthFactor * self.width
        return self.insetBy(dx: insetSpace, dy: insetSpace)
    }
}

extension SetCardView {
    private struct Squiggle {
        static let start = CGPoint(x: 1.05, y: 91.80)
        static let curvePoints = [(to: CGPoint(x: 94.50, y: 19.80), controlPoint: CGPoint(x: -9.00, y: -13.50)),
                              (to: CGPoint(x: 175.50, y: 10.80), controlPoint: CGPoint(x: 147.91, y: 36.00)),
                              (to: CGPoint(x: 208.65, y: 19.80), controlPoint: CGPoint(x: 198.00, y: -13.50)),
                              (to: CGPoint(x: 115.20, y: 91.80), controlPoint: CGPoint(x: 218.70, y: 125.10)),
                              (to: CGPoint(x: 34.20, y: 100.80), controlPoint: CGPoint(x: 62.69, y: 75.60)),
                              (to: CGPoint(x: 1.05, y: 91.80), controlPoint: CGPoint(x: 11.70, y: 125.10))]
    }
    
    private struct SizeRatio {
        static let percentShapeWidth: CGFloat = 0.8
        static let percentShapeHeightToShapeWidth: CGFloat = 0.5
        static let percentShapeInset: CGFloat = (1 - SizeRatio.percentShapeWidth) / 2
        static let cardBorderWeight: CGFloat = 15.0
        static let stripeWeight: CGFloat = 5.0
        static let stripeSpaceWeight: CGFloat = 20.0
        static let shapeBorderWeight: CGFloat = 10.0
        static let corner: CGFloat = 4.0
        static let spaceBetweenCards: CGFloat = 0.05
    }
    
    private struct Animation {
        static let dealSpeed: Double = 0.6
        static let resizeSpeed: Double = 1.0
        static let cardFlipSpeed: Double = 1.0
    }
    
    private var quarterTurn: CGFloat {
        return 0.5 * CGFloat.pi // quarter turn is 1/4 of 2 * pi
    }
    
    private var shapeWidth: CGFloat {
        return SizeRatio.percentShapeWidth * useableCardBox.width
    }
    
    private var shapeInset: CGFloat {
        return SizeRatio.percentShapeInset * useableCardBox.width
    }
    
    private var shapeHeight: CGFloat {
        return SizeRatio.percentShapeHeightToShapeWidth * shapeWidth
    }
    
    private var stripeWidth: CGFloat {
        return SizeRatio.stripeWeight * cardSizeScaleFactor
    }
    
    private var stripeSpaceWidth: CGFloat {
        return SizeRatio.stripeSpaceWeight * cardSizeScaleFactor
    }
    
    private var cardBorderWidth: CGFloat {
        return SizeRatio.cardBorderWeight * cardSizeScaleFactor
    }
    
    private var shapeBorderWidth: CGFloat {
        return SizeRatio.shapeBorderWeight * cardSizeScaleFactor
    }
    
    private var cornerRadius: CGFloat {
        return useableCardBox.width / SizeRatio.corner
    }
    
}
