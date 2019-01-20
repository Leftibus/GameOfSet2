//
//  DiscardBehavior.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 1/1/19.
//  Copyright © 2019 Kevin Wojtas. All rights reserved.
//
// class that contains all of the relevant dynamic animation code
// to keep the viewcontroller clean

import UIKit

class DiscardBehavior: UIDynamicBehavior {
    
    lazy var discardCollisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var discardItemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 1.0
        behavior.resistance = 0.5
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let cardPush = UIPushBehavior(items: [item], mode: .instantaneous)
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x,y) where x < center.x && y > center.y: //lower left quadrant, push up/right
                cardPush.angle = CGFloat.pi*(1/8) + (CGFloat.pi/4).arc4random
            case let (x,y) where x < center.x && y < center.y: //upper left quadrant, push down/right
                cardPush.angle = CGFloat.pi*(5/8) + (CGFloat.pi/4).arc4random
            case let (x,y) where x > center.x && y < center.y: //upper right quadrant, push down/left
                cardPush.angle = CGFloat.pi*(9/8) + (CGFloat.pi/4).arc4random
            case let (x,y) where x > center.x && y > center.y: //lower right quadrant, push up/left
                cardPush.angle = CGFloat.pi*(13/8) + (CGFloat.pi/4).arc4random
            default:
                cardPush.angle = (CGFloat.pi*2).arc4random
            }
        }
        cardPush.magnitude = 7.5
        cardPush.action = { [unowned cardPush, weak self] in
            self?.removeChildBehavior(cardPush)
        }
        addChildBehavior(cardPush)
    }
    
    func addItem (_ item: UIDynamicItem) {
        discardCollisionBehavior.addItem(item)
        discardItemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem (_ item: UIDynamicItem) {
        discardCollisionBehavior.removeItem(item)
        discardItemBehavior.removeItem(item)
        
    }
    
    override init() {
        super.init()
        addChildBehavior(discardCollisionBehavior)
        addChildBehavior(discardItemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
