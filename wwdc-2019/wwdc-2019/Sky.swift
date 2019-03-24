//
//  Sky.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/24/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

extension DakotaViewController {
    
    func createSkyView() -> UIView {
        return UIView(frame: view.bounds)
    }
    
    func createSkyGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(rgb: 0x000428, a: 1.0).cgColor, // dark blue
            UIColor(rgb: 0x004E92, a: 1.0).cgColor] // light blue
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }
    
}
