//
//  Cornfield.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/21/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

class CornstalkSnapBehavior: UISnapBehavior {
    var origin = CGPoint(x: 0, y: 0)
}

extension ViewController {
    
    func generateCornfield(count: Int) {
        let interval = (view.bounds.width + 400) / CGFloat(count + 1)
        
        var snapBehaviors = [CornstalkSnapBehavior]()
        var stalks = [CornstalkImageView]()
        
        for stalk in 1 ... count {
            
            // MARK: - Size Definitions
            
            // Center x of the cornstalk. Cornstalks run 200px off the screen on both sides
            let cx = (CGFloat(stalk) * (interval)) - 200
            
            // Random height and width for cornstalk
            let size = CGSize(width: CGFloat.random(in: 80 ... 140), height: CGFloat.random(in: 240 ... 340))
            
            // Anchor point to rotate around, the center of the bottom of the cornstalk
            let anchor = CGPoint(x: cx, y: view.bounds.maxY + 100)
            
            // Create cornstalk & add it to the view
            let cs = CornstalkImageView(frame: CGRect(x: anchor.x - (size.width / 2), y: anchor.y - size.height, width: size.width, height: size.height))
            view.addSubview(cs)
            stalks.append(cs)
            
            // MARK: - UIDynamicBehavior
            
            // Create and add the pin behavior
            let pinBehaviour = UIAttachmentBehavior(item: cs, offsetFromCenter: UIOffset(horizontal: 0, vertical: size.height / 2), attachedToAnchor: anchor)
            pinBehaviour.attachmentRange = UIFloatRange(minimum: 0, maximum: 1)
            animator.addBehavior(pinBehaviour)
            
            // Create and add the snap behavior. Allow it to be manipulated later
            let snapPoint = CGPoint(x: anchor.x, y: anchor.y - size.height)
            let snapBehavior = CornstalkSnapBehavior(item: cs, snapTo: snapPoint)
            snapBehavior.origin = snapPoint
            snapBehavior.damping = 30.0
            animator.addBehavior(snapBehavior)
            snapBehaviors.append(snapBehavior)
        }
        
        // Add a resistance property to the stalk
        let resistanceBehavior = UIDynamicItemBehavior(items: stalks)
        resistanceBehavior.resistance = CGFloat.random(in: 45 ... 60)
        animator.addBehavior(resistanceBehavior)
        
        self.cornstalks = stalks
        self.cornstalkSnapBehaviors = snapBehaviors
        
    }
    
    @objc func pulseCornstalks() {
        for stalk in cornstalks {
            let push = UIPushBehavior(items: [stalk], mode: .instantaneous)
            push.angle = Bool.random() ? 0.0 : CGFloat.pi
            push.magnitude = CGFloat.random(in: 50 ... 200)
            animator.addBehavior(push)
        }
    }
    
    func randoFunc(_ animated: Bool) {

        let anchorPoint = CGPoint(x: view.bounds.midX, y: view.bounds.maxY + 100)
        let cornstalk = CornstalkImageView(frame: CGRect(x: view.bounds.midX - 55, y: anchorPoint.y - 300, width: 110, height: 300))
        view.addSubview(cornstalk)
        
        // Dragging an element with a PanGestureRecognizer for instance
        let pinBehaviour = UIAttachmentBehavior(item: cornstalk, offsetFromCenter: UIOffset(horizontal: 0, vertical: cornstalk.bounds.height / 2), attachedToAnchor: anchorPoint)
        //pinBehaviour.length = 0
        //pinBehaviour.damping = 5.0
        //pinBehaviour.frictionTorque = 5.0
        pinBehaviour.attachmentRange = UIFloatRange(minimum: 0, maximum: 1)
        animator.addBehavior(pinBehaviour)
        
        let dynamicBehavior = UIDynamicItemBehavior(items: [cornstalk])
        //dynamicBehavior.angularResistance = 40.0
        dynamicBehavior.resistance = 50.0
        //dynamicBehavior.friction = 2.0
        //dynamicBehavior.density = 20.0
        
        animator.addBehavior(dynamicBehavior)
        
        /*cornSnap = UISnapBehavior(item: cornstalk, snapTo: CGPoint(x: anchorPoint.x, y: anchorPoint.y - 300))
        cornSnap.damping = 30.0
        animator.addBehavior(cornSnap)*/
        
        /*
         let anchorView = UIView(frame: CGRect(x: 0, y: view.bounds.maxY + 50, width: 10, height: 1))
         view.addSubview(anchorView)
         let anchorBehavior = UIAttachmentBehavior(item: anchorView, attachedToAnchor: CGPoint(x: view.bounds.midX, y: view.bounds.maxY + 50))
         animator.addBehavior(anchorBehavior)
         let pinBehavior = UIAttachmentBehavior.pinAttachment(with: cornstalk, attachedTo: anchorView, attachmentAnchor: CGPoint(x: view.bounds.midX, y: view.bounds.maxY + 50))
         pinBehavior.attachmentRange = UIFloatRange(minimum: -1.0, maximum: 1.0)
         pinBehavior.length = 0
         animator.addBehavior(pinBehavior)*/
        
        /*cornPush = UIPushBehavior(items: [cornstalk], mode: .instantaneous)
        cornPush.angle = .pi
        cornPush.magnitude = 20.0
        animator.addBehavior(cornPush)*/
        
        
        //gravity = UIGravityBehavior(items: [button])
        //animator.addBehavior(gravity)
        //collision = UICollisionBehavior(items: [button, cornstalk])
        //collision.addBoundary(withIdentifier: NSString(string: "left"), from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: view.bounds.maxY))
        //collision.translatesReferenceBoundsIntoBoundary = true
        //animator.addBehavior(collision)
        
        // Add pan gesture for manipulating the stars
        //let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handlePanGesture(_:))))
        //self.view.addGestureRecognizer(panGesture)
        
        // Add parralax effect to skyView
        addParallaxToView(vw: skyView)
    }
}
