//
//  MoonImageView.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/21/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

class MoonImageView: UIImageView, CAAnimationDelegate {
    
    struct Orbit {
        var center: CGPoint
        var origin: CGPoint
        var radius: CGFloat
        var position: Int
        var totalPositions: Int
    }
    
    var orbitInfo: Orbit?
    var animationInProgress = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImage(named: "moon")
        contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func increasePosition() {
        guard let orbit = orbitInfo, animationInProgress == false else { return }
        animationInProgress = true
        addAnimation(to: orbit.position + 1, from: orbit.position, of: orbit.totalPositions)
        self.orbitInfo?.position += 1
    }
    
    func addAnimation(to position: Int, from pastPosition: Int, of totalPositions: Int) {
        guard let orbit = orbitInfo else { return }
        
        let startAngle = (2.0 * CGFloat.pi) - ((CGFloat(pastPosition) / CGFloat(totalPositions)) * (CGFloat.pi / 2.0))
        let endAngle = (2.0 * CGFloat.pi) - ((CGFloat(position) / CGFloat(totalPositions)) * (CGFloat.pi / 2.0))
        
        let path = UIBezierPath(arcCenter: orbit.center, radius: orbit.radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        let endOfPath = path.currentPoint
        
        print("animate path: \(path.cgPath)")
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.duration = 1
        animation.repeatCount = 0
        animation.path = path.cgPath
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        self.layer.add(animation, forKey: "moonAnimation")
        
        self.frame = CGRect(x: endOfPath.x - 160, y: endOfPath.y - 160, width: 320, height: 320)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationInProgress = false
    }
}
