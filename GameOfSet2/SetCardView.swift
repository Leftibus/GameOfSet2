//
//  SetCardView.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 7/29/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    var currentCard: Card?
    private var useableCardBox = CGRect()
    private var okToDealIn = true
    private var endFrame = CGRect()
    private var showDelay = Double()
    var isFaceUp = false
    private(set) var borderColor = UIColor()
    
    init(startFrame: CGRect, endFrame: CGRect, showDelay: Double, card: Card? = nil) {
        currentCard = card
        super.init(frame: startFrame)
        self.transform = CGAffineTransform(rotationAngle: -0.5 * CGFloat.pi)
        self.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0)
        self.endFrame = endFrame
        self.showDelay = showDelay
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let squiggleStartPoint = CGPoint(x: 1.05, y: 91.80)
    private let squigglePoints = [(to: CGPoint(x: 94.50, y: 19.80), controlPoint: CGPoint(x: -9.00, y: -13.50)),
                               (to: CGPoint(x: 175.50, y: 10.80), controlPoint: CGPoint(x: 147.91, y: 36.00)),
                               (to: CGPoint(x: 208.65, y: 19.80), controlPoint: CGPoint(x: 198.00, y: -13.50)),
                               (to: CGPoint(x: 115.20, y: 91.80), controlPoint: CGPoint(x: 218.70, y: 125.10)),
                               (to: CGPoint(x: 34.20, y: 100.80), controlPoint: CGPoint(x: 62.69, y: 75.60)),
                               (to: CGPoint(x: 1.05, y: 91.80), controlPoint: CGPoint(x: 11.70, y: 125.10))]
    
    override func draw(_ rect: CGRect) {
        
        // draws all of the cards in play, which captures any changes to selection (including set checks)
        // and to the number of cards in play
        
        var fillColor = UIColor()
        let cardHolderView = superview?.frame
        
        // scale accounts for scaling when the device is landscape versus portrait
        let scale = rect.width / (cardHolderView!.height > cardHolderView!.width ? cardHolderView!.width : cardHolderView!.height)
        
        // inset card so there is space between cards.
        useableCardBox = rect.insetBy(dx: 0.05 * rect.width, dy: 0.05 * rect.width)
        let borderPath = UIBezierPath(roundedRect: useableCardBox, cornerRadius: useableCardBox.width / 4)
        
        if let cardToDraw = currentCard {

            if isFaceUp {
                fillColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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
                fillColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
                borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            }
            
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            context.saveGState()
            borderPath.addClip()
            fillColor.setFill()
            borderPath.fill()
            
            //draw border based on cardMatchState
            borderColor.setStroke()
            borderPath.lineWidth = 15.0 * scale
            borderPath.stroke()
            
            context.restoreGState()
            
            if isFaceUp { drawCardShapes(area: useableCardBox, scale: scale) }
            
        }
        
        if okToDealIn {
            okToDealIn = false
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: showDelay,
                options: [.layoutSubviews],
                animations: {
                    self.transform = CGAffineTransform(rotationAngle: 1.0 * CGFloat.pi)
                    self.frame = self.endFrame
            },
                completion: { if $0 == .end {
                    UIView.transition(with: self,
                                      duration: 1.0,
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
    
    func drawCardShapes(area: CGRect, scale: CGFloat) {
    
        let shapeCount = currentCard!.numberOfSymbols
        let shapeType = currentCard!.cardSymbols
        let shapeFillType = currentCard!.shadingofSymbols
        var shapeColor: UIColor
        var shapePath: UIBezierPath
        
        switch currentCard!.colorOfSymbols {
        case .green:
            shapeColor = .green
        case .purple:
            shapeColor = .purple
        case .red:
            shapeColor = .red
        }
        
        let shapeDivider = useableCardBox.height / CGFloat(shapeCount + 1)
        // build shape path and bounds
        for shapeIndex in 1...shapeCount {
            
            let centerY = CGFloat(shapeIndex) * shapeDivider
            
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
            shapePath.lineWidth = 10.0 * scale
            shapePath.addClip()
            
            switch shapeFillType {
            case .striped:
                fillStripes(shapeBounds: shapePath.bounds, scale: scale)
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
        
        shapePath.move(to: squiggleStartPoint)

        for curve in squigglePoints {
            shapePath.addQuadCurve(to: curve.to, controlPoint: curve.controlPoint)
        }
        let scale = (0.8 * useableCardBox.width) / shapePath.bounds.width
        
        let newTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        shapePath.apply(newTransform)
        
        let currentCenter = shapePath.bounds.center
        let desiredCenter = CGPoint(x: useableCardBox.width / 2, y: centerY)
        let deltaX = desiredCenter.x - currentCenter.x
        let deltaY = desiredCenter.y - currentCenter.y
        let newTranslation = CGAffineTransform(translationX: deltaX + useableCardBox.origin.x, y: deltaY + useableCardBox.origin.y)
        
        shapePath.apply(newTranslation)
        
        return shapePath
    }
    
    func makeDiamondPath(with centerY: CGFloat) -> UIBezierPath {
        let shapePath = UIBezierPath()
        let diamondWidth = 0.8 * useableCardBox.width
        let diamondHeight = 0.5 * diamondWidth
        let newCenter = useableCardBox.origin.add(CGPoint(x: useableCardBox.width/2, y: centerY))
        
        shapePath.move(to: newCenter.add(CGPoint(x: -diamondWidth/2, y: 0)))
        shapePath.addLine(to: newCenter.add(CGPoint(x: 0, y: -diamondHeight/2)))
        shapePath.addLine(to: newCenter.add(CGPoint(x: diamondWidth/2, y: 0)))
        shapePath.addLine(to: newCenter.add(CGPoint(x: 0, y: diamondHeight/2)))
        shapePath.close()
        
        return shapePath
    }
    
    func makeOvalPath(with centerY: CGFloat) -> UIBezierPath {
        let ovalWidth = 0.8 * useableCardBox.width
        let ovalHeight = 0.5 * ovalWidth
        let newOrigin = useableCardBox.origin.add(CGPoint(x: 0.1 * useableCardBox.width, y: centerY - ovalHeight/2))
        let ovalRect = CGRect(x: newOrigin.x, y: newOrigin.y, width: ovalWidth, height: ovalHeight)
        
        return UIBezierPath(roundedRect: ovalRect, cornerRadius: ovalHeight / 2)
    }
    
    func fillStripes(shapeBounds: CGRect, scale: CGFloat) {
        let stripePath = UIBezierPath()
        for yPos in stride(from: CGFloat(shapeBounds.origin.y), through: shapeBounds.origin.y + shapeBounds.height, by: 15.0 * scale) {
            stripePath.move(to: CGPoint(x: shapeBounds.origin.x, y: yPos))
            stripePath.addLine(to: CGPoint(x: shapeBounds.origin.x + shapeBounds.size.width, y: yPos))
        }
        stripePath.lineWidth = 3.0 * scale
        stripePath.stroke()
    }
    
    func updateCard() {
        setNeedsDisplay()
        setNeedsLayout()
    }
    func setCard(frame: CGRect, card: Card){
        currentCard = card
       
        if self.endFrame != frame {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 1.0,
                delay: 0.0,
                options: [.layoutSubviews],
                animations: { self.frame = frame },
                completion: nil )
        }
        self.endFrame = frame
         superview!.sendSubviewToBack(self)
        updateCard()
    }
}

private extension CGPoint {
    func add(_ second: CGPoint) -> CGPoint {
        let newX = self.x + second.x
        let newY = self.y + second.y
        return CGPoint(x: newX, y: newY)
    }
}
private extension CGRect {
    var area: CGFloat {
        return width * height
    }
    var center: CGPoint {
        get {
            return CGPoint(x: origin.x + (width / 2), y: origin.y + (height / 2))
        }
        set {
            origin = CGPoint(x: center.x - (width / 2), y: center.y - (height / 2))
        }
    }
}
