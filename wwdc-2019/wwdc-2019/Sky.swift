//
//  Sky.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/20/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

extension ViewController {
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            skyView.layer.removeAnimation(forKey: "skyboxRotation")
            print("began")
        case .changed:
            let translation = sender.translation(in: view)
            let altitude = sender.location(in: view).y
            //skyView.transform = CGAffineTransform(rotationAngle: (translation.x / skyView.bounds.width) * 2 * CGFloat.pi)
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            let rotateValue = CGFloat(.pi * 2.0) * (translation.x / skyView.bounds.width) * 0.01
            rotateAnimation.toValue = rotateValue
            rotateAnimation.duration = 0.01
            rotateAnimation.repeatCount = 0
            skyView.layer.add(rotateAnimation, forKey: nil)
            skyView.transform = skyView.transform.rotated(by: rotateValue)
            print("changed")
            
            cornstalkSnapBehaviors.forEach({
                let loc = sender.location(in: view)
                $0.snapPoint = (loc.x < $0.origin.x) ?
                    (CGPoint(x: max($0.origin.x - 200, loc.x), y: loc.y)) :
                    (CGPoint(x: min($0.origin.x + 200, loc.x), y: loc.y))
            })
            
        case .ended:
            let translation = sender.translation(in: view)
            let altitude = sender.location(in: view).y
            //skyView.transform = CGAffineTransform(rotationAngle: (translation.x / skyView.bounds.width) * 2 * CGFloat.pi)
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            let rotateValue = CGFloat(.pi * 2.0) * (translation.x / skyView.bounds.width) * 0.01
            rotateAnimation.toValue = rotateValue
            rotateAnimation.duration = 0.01
            rotateAnimation.repeatCount = 0
            skyView.layer.add(rotateAnimation, forKey: nil)
            skyView.transform = skyView.transform.rotated(by: rotateValue)
            
            cornstalkSnapBehaviors.forEach({ $0.snapPoint = $0.origin })
            //cornSnap.snapPoint = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 300)
            resumeSkyboxRotation()
            print("ended")
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

/*
let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
rotateAnimation.fromValue = 0.0
rotateAnimation.toValue = -CGFloat(.pi * 2.0)
//rotateAnimation.duration = 1000.0
rotateAnimation.duration = 500.0
rotateAnimation.repeatCount = .greatestFiniteMagnitude
skyView.layer.add(rotateAnimation, forKey: nil)
*/
