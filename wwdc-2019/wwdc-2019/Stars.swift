//
//  Sky.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/20/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

extension DakotaViewController {
    
    // MARK: - Constellation
    func createConstellationLayer() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: view.center.y)
        emitter.emitterShape = .rectangle
        emitter.emitterSize = CGSize(width: view.frame.size.width * 2, height: view.frame.size.height * 2)
        let cell = CAEmitterCell()
        cell.lifetime = 2000.0
        cell.scale = 0.1
        cell.scaleRange = 0.09
        cell.contents = UIImage(named: "star-circle.png")!.cgImage
        cell.birthRate = 1
        emitter.emitterCells = [cell]
        return emitter
    }
    
    func fadeInConstellationLayer() {
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0.0
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.duration = 2.0
        constellationLayer.add(fadeInAnimation, forKey: nil)
    }
    
    func fadeInWWDCLayer() {
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0.0
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.duration = 2.0
        wwdcLayer.opacity = 1.0
        wwdcLayer.add(fadeInAnimation, forKey: nil)
    }
    
    @objc func rotateStars() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat(.pi * 2.0)
        rotateAnimation.duration = 300.0
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        skyView.layer.add(rotateAnimation, forKey: "skyboxRotation")
    }
    
    func addParallaxToView(vw: UIView) {
        let amount = 100
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            let loc = sender.location(in: view)
            if moonSnappingBehaviors == nil {
                moonSnappingBehaviors = [UISnapBehavior]()
            }
            
            moonBalls?.forEach({ (moon) in
                let snappingBehavior = UISnapBehavior(item: moon, snapTo: loc)
                snappingBehavior.damping = 4.0
                animator.addBehavior(snappingBehavior)
                moonSnappingBehaviors?.append(snappingBehavior)
            })
            
            if firefliesLayers.0.birthRate == 0 {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (_) in
                    self.firefliesLayers.0.birthRate = min(self.firefliesLayers.0.birthRate + 0.05, 1.0)
                    self.firefliesLayers.1.birthRate = min(self.firefliesLayers.1.birthRate + 0.05, 1.0)
                }
            }
            
        case .changed:
            let loc = sender.location(in: view)
            cornstalkSnapBehaviors.forEach({
                $0.snapPoint = (loc.x < $0.origin.x) ?
                    (CGPoint(x: max($0.origin.x - 200, loc.x), y: loc.y)) :
                    (CGPoint(x: min($0.origin.x + 200, loc.x), y: loc.y))
            })
            
            if let moonRopeFrame = self.moonRopeFrame {
                if moonRopeFrame.contains(sender.location(in: view)) {
                    swipeMoonRope()
                }
            }
            
            if let moonSnaps = moonSnappingBehaviors {
                moonSnaps.forEach { (snap) in
                    snap.snapPoint = loc
                }
            }
            
        case .ended:
            cornstalkSnapBehaviors.forEach({ $0.snapPoint = $0.origin })
            if let moonSnaps = moonSnappingBehaviors {
                moonSnaps.forEach { (snap) in
                    animator.removeBehavior(snap)
                }
            }
            moonSnappingBehaviors = nil
            
        default:
            break
        }
    }
    
    func resumeSkyboxRotation() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat(.pi * 2.0)
        //rotateAnimation.duration = 1000.0
        rotateAnimation.duration = 500.0
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        skyView.layer.add(rotateAnimation, forKey: "skyboxRotation")
    }
}
