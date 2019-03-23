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
        
        self.frame = CGRect(x: endOfPath.x - 90, y: endOfPath.y - 90, width: 180, height: 180)
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
        moonCollectionView.addSubview(newMoon)
        moonView.removeFromSuperview()
        
        // Draw the moon rope, add swipe recognizers
        moonRopeView = UIView(frame: CGRect(x: view.center.x - 1, y: 0, width: 2, height: newMoon.frame.minY))
        self.moonRopeFrame = CGRect(x: view.center.x - 10, y: -5, width: 20, height: newMoon.frame.minY + 10)
        moonRopeView!.backgroundColor = .gray
        moonRopeView!.alpha = 0.0
        view.addSubview(moonRopeView!)
        UIView.animate(withDuration: 1.0) {
            self.moonRopeView?.alpha = 1.0
        }

        
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
        
        // Add it to the ~collection~
        moonBalls = [UIDynamicItem]()
        moonBalls?.append(newMoon)
    }
    
    func spawnRandomMoon() {
        spawnMoon(with: CGRect(x: CGFloat.random(in: 20 ... view.bounds.width - 20), y: -400, width: 180, height: 180))
    }
    
    func spawnMoon(with frame: CGRect) {
        let newMoon = MoonImageView(frame: frame)
        moonCollectionView.addSubview(newMoon)
        gravity.addItem(newMoon)
        collision.addItem(newMoon)
        
        let props = UIDynamicItemBehavior(items: [newMoon])
        props.resistance = 0.8
        props.elasticity = 0.8
        animator.addBehavior(props)
        
        moonBalls?.append(newMoon)
    }
    
    func cutMoonRope() {
        moonRopeFrame = nil
        if let ropeBehavior = self.moonRopeBehaviour {
            self.animator.removeBehavior(ropeBehavior)
        }
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { _ in self.spawnRandomMoon() })
        
        UIView.animate(withDuration: 2.0) {
            self.moonRopeView?.alpha = 0.0
        }
        
        rotateStars()
    }
    
    @objc func swipeMoonRope() {
        // Cut the moon rope, if it still exists
        if moonRopeFrame != nil {
            cutMoonRope()
        }
    }
    
    @objc func pulseMoons(_ sender: UITapGestureRecognizer) {
        // Pulse the moons, if they exist
        if let moons = moonBalls, moonRopeFrame == nil {
            for moon in moons {
                let push = UIPushBehavior(items: [moon], mode: .instantaneous)
                push.angle = CGFloat.random(in: 0 ... CGFloat.pi * 2 )
                push.magnitude = CGFloat.random(in: 50 ... 150)
                animator.addBehavior(push)
            }
        }
        
        // Cut the moon rope, if it still exists
        if moonRopeFrame != nil {
            if moonRopeFrame?.contains(sender.location(in: view)) ?? false {
                cutMoonRope()
            }
        }
    }
}
