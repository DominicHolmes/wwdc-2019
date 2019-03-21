//
//  MoonImageView.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/21/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

class MoonImageView: UIImageView {
    
    struct Orbit {
        var center: CGPoint
        var origin: CGPoint
        var radius: CGFloat
    }
    
    var orbitInfo: Orbit?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImage(named: "moon")
        contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAnimation(to position: Int, from pastPosition: Int, of totalPositions: Int, in context: UIView) {
        guard let orbit = orbitInfo else { return }
        
        let startAngle = (2.0 * CGFloat.pi) - ((CGFloat(pastPosition) / CGFloat(totalPositions)) * (CGFloat.pi / 2.0))
        let endAngle = (2.0 * CGFloat.pi) - ((CGFloat(position) / CGFloat(totalPositions)) * (CGFloat.pi / 2.0))
        
        let path = UIBezierPath(arcCenter: orbit.center, radius: orbit.radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        print("animate path: \(path.cgPath)")
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.duration = 1
        animation.repeatCount = 0
        animation.path = path.cgPath
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false

        self.layer.add(animation, forKey: "moonAnimation")
        
        /*let pathLayer          = CAShapeLayer()
        pathLayer.path          = path.cgPath
        pathLayer.strokeColor   = UIColor.red.cgColor
        pathLayer.lineWidth     = 1.0
        pathLayer.fillColor     = nil
        
        self.layer.addSublayer(pathLayer)*/
    }
}
