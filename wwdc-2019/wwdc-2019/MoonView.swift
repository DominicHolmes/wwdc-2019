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
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
    
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

        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.duration = 2
        animation.repeatCount = 0
        animation.path = path.cgPath
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        self.layer.add(animation, forKey: "moonAnimation")
        
        self.frame = CGRect(x: endOfPath.x - 160, y: endOfPath.y - 160, width: 320, height: 320)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationInProgress = false
    }
}

extension ViewController {
    func addRope() {
        
        moonView.image = UIImage(named: "moon")
        moonView.layer.needsDisplayOnBoundsChange = true
        
        let newMoon = MoonImageView(frame: moonView.frame)
        view.addSubview(newMoon)
        moonView.removeFromSuperview()
        
        // Anchor point
        let ropeAnchor = CGPoint(x: newMoon.center.x, y: newMoon.center.y - (newMoon.bounds.height / 2))

        // Create and add the pin behavior
        moonRopeBehaviour = UIAttachmentBehavior(item: newMoon, offsetFromCenter: UIOffset(horizontal: 0, vertical: newMoon.bounds.height / -2), attachedToAnchor: ropeAnchor)
        moonRopeBehaviour!.attachmentRange = UIFloatRange(minimum: 0, maximum: 1)
        animator.addBehavior(moonRopeBehaviour!)
        
        // Give the rope pin some resistance (to stop it glitching around)
        let props = UIDynamicItemBehavior(items: [newMoon])
        props.resistance = 0.8
        props.elasticity = 0.8
        animator.addBehavior(props)
        
        // Give the moon that sweet sweet gravity
        gravity.addItem(newMoon)
        collision.addItem(newMoon)
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (_) in
            if let ropeBehavior = self.moonRopeBehaviour {
                self.animator.removeBehavior(ropeBehavior)
            }
        }
    }
    
    func spawnRandomMoon() {
        spawnMoon(with: CGRect(x: CGFloat.random(in: 20 ... view.bounds.width - 20), y: -400, width: 320, height: 320))
    }
    
    func spawnMoon(with frame: CGRect) {
        let newMoon = MoonImageView(frame: frame)
        view.addSubview(newMoon)
        gravity.addItem(newMoon)
        collision.addItem(newMoon)
        
        let props = UIDynamicItemBehavior(items: [newMoon])
        props.resistance = 0.8
        props.elasticity = 0.8
        animator.addBehavior(props)
    }
}
