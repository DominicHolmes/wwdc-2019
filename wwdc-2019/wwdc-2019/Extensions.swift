//
//  Extensions.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/24/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

// MARK: - Extensions
extension UIColor {
    // Credit: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values/36009030#36009030
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    // Credit: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values/36009030#36009030
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
}
