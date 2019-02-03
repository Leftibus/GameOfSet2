//
//  ConcentrationThemeChooserViewController.swift
//  Concentration
//
//  Created by Kevin Wojtas on 1/26/19.
//  Copyright © 2019 Kevin Wojtas. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController {

    let themes = [
        "Sports":"⚽️🏀🏈⚾️🏐🏉⛳️🎱🏒🎳",
        "Animals":"🐶🐱🐭🐹🐰🦊🐴🐷🐵🐸🐨🐼🐌",
        "Faces":"😍😡🙃😁😎🤢😱🤩😤🤫🤥"
    ]
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Theme" {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                if let cvc = segue.destination as? ConcentrationViewController {
                    cvc.theme = theme
                }
            }
        }
    }
}
