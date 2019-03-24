//
//  Cornfield.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/21/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

extension DakotaViewController {
    
    func createCornfield() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: view.bounds.height - 310, width: view.bounds.width, height: 320))
        imageView.contentMode = .topLeft
        imageView.image = UIImage(named: "")
        view.addSubview(imageView)
    }
    
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
}
