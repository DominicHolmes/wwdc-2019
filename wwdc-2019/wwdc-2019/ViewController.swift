//
//  DakotaViewController.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/15/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

class DakotaViewController: UIViewController {
    
    // UIDynamics
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    
    // Notifications
    let notificationCenter = NotificationCenter.default
    var isPanGestureActive: Bool = false
    
    // Haptic Feedback Engines
    let hapticImpact = UIImpactFeedbackGenerator()
    let hapticNotification = UINotificationFeedbackGenerator()
    
    // Skybox
    var skyView: UIView!
    var meteorView: UIView!
    var skyGradient: CAGradientLayer!
    
    // Stars
    var constellationLayer: CAEmitterLayer!
    var wwdcLayer: CALayer!
    
    // Moon
    var moonView: MoonImageView!
    var moonCollectionView: UIView!
    var moonBalls: [UIDynamicItem]?
    var moonSnappingBehaviors: [UISnapBehavior]?
    var moonRopeBehaviour: UIAttachmentBehavior?
    var moonRopeFrame: CGRect?
    var moonRopeView: UIView? = nil
    
    // Fireflies
    var firefliesLayers: (CAEmitterLayer, CAEmitterLayer)!
    
    // Meteor
    var meteorLoop: (Bool, Float) = (true, 0.5)
    var meteorTimer: Timer?
    
    // Corn
    var cornstalks: [CornstalkImageView]!
    var cornstalkSnapBehaviors: [CornstalkSnapBehavior]!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        
        /*let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 50, height: 20)
        label.text = ""
        label.textColor = .white
        view.addSubview(label)*/
        
        self.view = view
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add gradient to sky
        skyGradient = createSkyGradient()
        view.layer.addSublayer(skyGradient)
        
        // Create sky view (for stars etc)
        skyView = createSkyView()
        view.addSubview(skyView)
        
        // Create meteor view (so that these don't rotate)
        meteorView = UIView(frame: view.bounds)
        view.addSubview(meteorView)
        
        // Create stars with an emitter layer
        constellationLayer = createConstellationLayer()
        skyView.layer.addSublayer(constellationLayer)
        fadeInConstellationLayer()
        
        // Create WWDC layer, add it to the sky
        wwdcLayer = createWWDC()
        wwdcLayer.opacity = 0.0
        skyView.layer.addSublayer(wwdcLayer)
        
        // Create fireflies
        firefliesLayers = (createFirefliesLayer(), createFirefliesLayer())
        view.layer.addSublayer(firefliesLayers.0)
        
        // UIDynamics
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: [])
        collision = UICollisionBehavior(items: [])
        //collision.translatesReferenceBoundsIntoBoundary = true
        //collision.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsets(top: view.bounds.height, left: 10, bottom: 0, right: 10))
        collision.addBoundary(withIdentifier: NSString(string: "left"), from: CGPoint(x: -100, y: -4000), to: CGPoint(x: 0, y: view.bounds.height))
        collision.addBoundary(withIdentifier: NSString(string: "bottom"), from: CGPoint(x: 0, y: view.bounds.height), to: CGPoint(x: view.bounds.width, y: view.bounds.height))
        collision.addBoundary(withIdentifier: NSString(string: "right"), from: CGPoint(x: view.bounds.width + 100, y: view.bounds.height), to: CGPoint(x: view.bounds.width, y: -4000))
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        
        // Add the moon
        moonView = createMoon()
        moonCollectionView = UIView(frame: view.bounds)
        view.addSubview(moonCollectionView)
        view.addSubview(moonView)
        
        // Generate a dynamic cornfield
        generateCornfield(count: 80)
        
        // Add fireflies on top of corn
        view.layer.addSublayer(firefliesLayers.1)
        
        // Add pan gesture for manipulating the stars + rope cut
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handlePanGesture(_:))))
        self.view.addGestureRecognizer(panGesture)
        
        // Add double tap gesture for moving the moon
        let moonTap = UITapGestureRecognizer(target: self, action: #selector(moveMoon(_:)))
        moonTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(moonTap)
        
        // Add tap gesture to detect moon pulse + rope cut
        let tap = UITapGestureRecognizer(target: self, action: #selector(pulseMoons(_:)))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        // Add parralax effect to skyView
        addParallaxToView(vw: skyView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start listening to volume change events
        /*notificationCenter.addObserver(self,
                                       selector: #selector(systemVolumeDidChange),
                                       name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                       object: nil
        )*/
        
        meteorTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(spawnMeteors), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            self.moveMoon()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop listening to volume change events
        notificationCenter.removeObserver(self)
        //self.view.insertSubview(MPVolumeView(), aboveSubview: view)
        
        // Invalidate the meteor timer
        meteorTimer?.invalidate()
    }
    
    // Triggered when the volume is changed
    /*@objc func systemVolumeDidChange(notification: NSNotification) {
        print(notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float as Any)
        if let newVolume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            meteorLoop.1 = newVolume
            meteorLoop.0 = (newVolume > 0)
        }
    }*/
}

