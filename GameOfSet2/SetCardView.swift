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
    
    init(frame: CGRect, card: Card? = nil) {
        currentCard = card
        super.init(frame: frame)
        self.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
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
    
    private let diamondStartPoint = CGPoint(x: 0.00, y: 55.25)
    private let diamondPoints = [CGPoint(x: 104.69, y: 0.00),
                              CGPoint(x: 209.38, y: 55.25),
                              CGPoint(x: 104.69, y: 110.50)]
    
    private let ovalSize = CGSize(width: 209.38, height: 110.50)
    private let ovalCornerRadius: CGFloat = 40.0
    
    override func draw(_ rect: CGRect) {
        
        // draws all of the cards in play, which captures any changes to selection (including set checks)
        // and to the number of cards in play
        var insetFrame: CGRect
        var borderColor = UIColor.white
        let cardHolderView = superview?.frame
        
        if let cardToDraw = currentCard {
            // scale accounts for scaling when the device is landscape versus portrait
            let scale = rect.width / (cardHolderView!.height > cardHolderView!.width ? cardHolderView!.width : cardHolderView!.height)
            
            // inset card so there is space between.
            insetFrame = rect.insetBy(dx: 20 * scale, dy: 20 * scale)
            let borderPath = UIBezierPath(roundedRect: insetFrame, cornerRadius: 40.0 * scale)
            guard let context = UIGraphicsGetCurrentContext() else { return }

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
            
            context.saveGState()
            borderPath.addClip()
            UIColor.white.setFill()
            borderPath.fill()
            
            //draw border based on cardMatchState
            borderColor.setStroke()
            borderPath.lineWidth = 15.0 * scale
            borderPath.stroke()
            
            context.restoreGState()
            
            drawCardShapes(area: insetFrame, scale: scale)
        }
    }
    
    func drawCardShapes(area: CGRect, scale: CGFloat) {
    
        let shapeCount = currentCard!.numberOfSymbols
        let shapeType = currentCard!.cardSymbols
        let shapeFillType = currentCard!.shadingofSymbols
        var shapeColor: UIColor
        var shapePath: UIBezierPath
        var insetShapeFrame: CGRect
        
        switch currentCard!.colorOfSymbols {
        case .green:
            shapeColor = .green
        case .purple:
            shapeColor = .purple
        case .red:
            shapeColor = .red
        }

        let cardGrid = Grid(layout: Grid.Layout.dimensions(rowCount: shapeCount, columnCount: 1), frame: area)
        let shapeSizeScale = (0.7 * cardGrid[0]!.width) / 209.379
        
        let transform = CGAffineTransform(scaleX: shapeSizeScale, y: shapeSizeScale)
        
        for shapeIndex in 0..<shapeCount {
            
            // build shape path and bounds
            insetShapeFrame = cardGrid[shapeIndex]!.insetBy(dx: 20 * scale, dy: 20 * scale)
            
            switch shapeType {
            case .squiggle:
                shapePath = makeSquigglePath(frame: insetShapeFrame, shapeTransform: transform)
            case .diamond:
                shapePath = makeDiamondPath(frame: insetShapeFrame, shapeTransform: transform)
            case .oval:
                shapePath = makeOvalPath(frame: insetShapeFrame, shapeTransform: transform, scale: shapeSizeScale)
            }
            
            // create shapepath for unique shape
            
            let translate = CGAffineTransform(translationX: (insetShapeFrame.width - shapePath.bounds.width) / 2, y: (insetShapeFrame.height - shapePath.bounds.height) / 2)
            shapePath.apply(translate)
            
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
    
    func makeSquigglePath(frame: CGRect, shapeTransform: CGAffineTransform) -> UIBezierPath {
        let shapePath = UIBezierPath()
        
        shapePath.move(to: frame.origin.add(squiggleStartPoint.applying(shapeTransform)))
        
        for curve in squigglePoints {
            shapePath.addQuadCurve(to: frame.origin.add(curve.to.applying(shapeTransform)), controlPoint: frame.origin.add(curve.controlPoint.applying(shapeTransform)))
        }
        return shapePath
    }
    
    func makeDiamondPath(frame: CGRect, shapeTransform: CGAffineTransform) -> UIBezierPath {
        let shapePath = UIBezierPath()
        
        shapePath.move(to: frame.origin.add(diamondStartPoint.applying(shapeTransform)))
        
        for point in diamondPoints {
            shapePath.addLine(to: frame.origin.add(point.applying(shapeTransform)))
        }
        shapePath.close()
        
        return shapePath
    }
    
    func makeOvalPath(frame: CGRect, shapeTransform: CGAffineTransform, scale: CGFloat) -> UIBezierPath {
        let newFrame = CGRect(origin: frame.origin, size: ovalSize.applying(shapeTransform))
        return UIBezierPath(roundedRect: newFrame, cornerRadius: ovalCornerRadius * scale)
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
        self.frame = frame
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
}
