//
//  Meteor.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/24/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

extension DakotaViewController {
    
    // MARK: - Meteor spawning logic
    @objc func spawnMeteors() {
        
        guard meteorLoop.0 == true && meteorLoop.1 > 0 else { return }
        
        let widthOffset = view.bounds.width / 2.0
        
        for _ in 0 ... Int(2 * meteorLoop.1) {
            
            let timeOff = Double.random(in: 0.0 ... 4.0)
            let radius = CGFloat.random(in: 150 ... 250)
            let xoff = CGFloat.random(in: -widthOffset + radius ... widthOffset)
            let yoff = CGFloat.random(in: radius + 20 ... radius + 150)
            
            let params = MeteorParams(radius: radius,
                                      startAngleFuzz: CGFloat.random(in: -0.1...0.05),
                                      endAngleFuzz: CGFloat.random(in: -0.05...0.1),
                                      origin: CGPoint(x: view.center.x + xoff, y: yoff))
            DispatchQueue.main.asyncAfter(deadline: .now() + timeOff) {
                self.spawnMeteor(with: params)
            }
        }
    }
    
    // MARK: - Meteor creation logic
    struct MeteorParams {
        let radius: CGFloat
        let startAngleFuzz: CGFloat
        let endAngleFuzz: CGFloat
        let origin: CGPoint
    }
    
    func spawnMeteor(with params: MeteorParams) {
        let r: CGFloat = params.radius
        let pi = CGFloat.pi
        let origin = params.origin
        
        let startAngleMult = 1.4 + params.startAngleFuzz
        let endAngleMult = 1.1 + params.endAngleFuzz
        
        let start = CGPoint(x: r + r * cos(startAngleMult * pi), y: r + r * sin(startAngleMult * pi))
        let end = CGPoint(x: r + r * cos(endAngleMult * pi), y: r + r * sin(endAngleMult * pi))
        
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addArc(withCenter: CGPoint(x: r, y: r), radius: r, startAngle: startAngleMult * pi, endAngle: endAngleMult * pi, clockwise: false)
        
        let meteorMask = CAShapeLayer()
        meteorMask.path = path.cgPath
        meteorMask.frame = CGRect(x: 0, y: 0, width: r * 2, height: r * 2)
        meteorMask.lineCap = .round
        meteorMask.strokeColor = UIColor.white.cgColor
        meteorMask.fillColor = UIColor.clear.cgColor
        meteorMask.lineWidth = 1.0
        meteorMask.strokeStart = 0.0
        meteorMask.strokeEnd = 1.0
        meteorMask.opacity = 0.0
        
        // Create and add the gradient layer
        let meteorGradient = CAGradientLayer()
        meteorGradient.frame = CGRect(x: origin.x - r, y: origin.y - r, width: r * 2, height: r * 2)
        meteorGradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        
        let gradientTail = CGPoint(x: start.x / r,
                                   y: start.y / r)
        let gradientHead = CGPoint(x: end.x / r,
                                   y: end.y / r)
        meteorGradient.startPoint = gradientTail
        meteorGradient.endPoint = gradientHead
        meteorGradient.locations = [0.0, 1.0]
        meteorGradient.mask = meteorMask
        
        // Create stroke animations
        let strokeStartAnimation = CABasicAnimation(
            keyPath: "strokeStart")
        strokeStartAnimation.fromValue = -0.5
        strokeStartAnimation.toValue = 0.3
        //strokeStartAnimation.duration = 0.7
        strokeStartAnimation.duration = 1.2
        
        let strokeEndAnimation = CABasicAnimation(
            keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        strokeEndAnimation.duration = 1.2
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 1.0, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.5, 1.0]
        opacityAnimation.duration = 1.2
        
        // Add the meteor gradient to the view
        meteorView.layer.addSublayer(meteorGradient)
        
        // Animate the meteor mask
        meteorMask.add(strokeStartAnimation, forKey: "meteorAnimation")
        meteorMask.add(strokeEndAnimation, forKey: "meteorEndAnimation")
        meteorMask.add(opacityAnimation, forKey: "meteorOpacityAnimation")
    }
}
