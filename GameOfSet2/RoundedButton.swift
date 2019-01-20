//
//  RoundedButton.swift
//  GameOfSet2
//
//  Created by Kevin Wojtas on 10/13/18.
//  Copyright © 2018 Kevin Wojtas. All rights reserved.
//
// custome view for the Deal button to make rounded corners

import UIKit

class RoundedButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 4
        
    }
}
