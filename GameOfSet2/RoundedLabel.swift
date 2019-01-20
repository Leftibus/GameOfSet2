//
//  RoundedLabel.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 1/1/19.
//  Copyright © 2019 Kevin Wojtas. All rights reserved.
//
// custome view for the discard pile label to make rounded corners

import UIKit

class RoundedLabel: UILabel {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 4
        layer.masksToBounds = true
        
    }

}
