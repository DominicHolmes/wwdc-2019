import UIKit
import PlaygroundSupport

class DakotaViewController: UIViewController {
    
    // UIDynamics
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    
    // Notifications
    let notificationCenter = NotificationCenter.default
    var isPanGestureActive: Bool = false
    
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
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(moveMoon(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
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

// MARK: -- Stars
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
        cell.contents = UIImage(named: "star-circle.png")?.cgImage
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

// MARK: - Sky
extension DakotaViewController {
    
    func createSkyView() -> UIView {
        return UIView(frame: view.bounds)
    }
    
    func createSkyGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(rgb: 0x000428, a: 1.0).cgColor, // dark blue
            UIColor(rgb: 0x004E92, a: 1.0).cgColor] // light blue
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }
}

// MARK: - Moon
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

extension DakotaViewController {
    
    // MARK: - Moon
    func createMoon() -> MoonImageView {
        
        let moonTopOffset: CGFloat = 190.0
        let radius = view.bounds.height
        let moonOrigin = CGPoint(x: view.center.x + radius, y: view.bounds.maxY + moonTopOffset)
        let moon = MoonImageView(frame: CGRect(x: moonOrigin.x, y: moonOrigin.y, width: 180, height: 180))
        moon.orbitInfo = MoonImageView.Orbit(center: CGPoint(x: view.center.x, y: moonOrigin.y), origin: moonOrigin, radius: view.bounds.height, position: 3, totalPositions: 7)
        
        return moon
    }
    
    @objc func moveMoon(_ gestureRecognizer : UITapGestureRecognizer) {
        if moonView.frame.contains(gestureRecognizer.location(in: view)) {
            moveMoon()
        }
    }
    
    func moveMoon() {
        guard !moonView.animationInProgress, let orbit = moonView.orbitInfo, orbit.position < orbit.totalPositions else { return }
        moonView.increasePosition()
        
        if orbit.position == orbit.totalPositions - 1 {
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
                print("FADE IN WWDC")
                self.fadeInWWDCLayer()
                self.addRope()
            }
        }
    }
    
    // Add the rope that ties the moon to the top of the screen
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true, block: { _ in
                if (self.moonBalls?.count ?? 0) < 20 {
                    self.spawnRandomMoon()
                }
            })
        })
        
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
        pulseMoons()
        
        // Cut the moon rope, if it still exists
        if moonRopeFrame != nil {
            if moonRopeFrame?.contains(sender.location(in: view)) ?? false {
                cutMoonRope()
            }
        }
    }
    
    func pulseMoons() {
        // Pulse the moons, if they exist
        if let moons = moonBalls, moonRopeFrame == nil {
            for moon in moons {
                let push = UIPushBehavior(items: [moon], mode: .instantaneous)
                push.angle = CGFloat.random(in: -0.5 ... CGFloat.pi + 0.5)
                push.magnitude = CGFloat.random(in: 50 ... 100)
                animator.addBehavior(push)
            }
        }
    }
}


// MARK: - Meteor
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

// MARK: - Fireflies
extension DakotaViewController {
    func createFirefliesLayer() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: view.bounds.maxY + 5)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.birthRate = 0.0
        
        
        let cell = CAEmitterCell()
        cell.lifetime = 10
        
        cell.contents = UIImage(named: "firefly.png")?.cgImage
        cell.birthRate = 8
        
        // Emission angles and acceleration
        cell.emissionLongitude = 2 * .pi
        cell.emissionRange = .pi * 0.3
        cell.xAcceleration = CGFloat.random(in: -2 ... 2)
        cell.yAcceleration = CGFloat.random(in: -2 ... 3)
        
        cell.velocity = 20
        cell.velocityRange = 4
        
        // Scale
        cell.scale = 0.5
        cell.scaleRange = 0.1
        cell.scaleSpeed = -0.5 / CGFloat(cell.lifetime)
        
        // Alpha
        cell.alphaSpeed = -1.0 / cell.lifetime
        
        emitter.emitterCells = [cell]
        return emitter
    }
    
    // Create WWDC stars layer by getting a path from the glyphs of CTFont characters
    func createWWDC() -> CALayer {
        let font = UIFont(name: "AvenirNext-DemiBold", size: 200)!
        
        var chars = [UniChar]("WWDC".utf16)
        var glyphs = [CGGlyph](repeating: 0, count: chars.count)
        let doCharsHaveGlyphs = CTFontGetGlyphsForCharacters(font, &chars, &glyphs, chars.count)
        if doCharsHaveGlyphs {
            let wwdcPath = UIBezierPath()
            for eachGlyph in glyphs.indices {
                let cgpath = CTFontCreatePathForGlyph(font, glyphs[eachGlyph], nil)!
                let path = UIBezierPath(cgPath: cgpath)
                let kerning = (eachGlyph == 3) ? (200.0 * CGFloat(eachGlyph)) - 50.0 : 200.0 * CGFloat(eachGlyph)
                path.apply(CGAffineTransform(translationX: kerning, y: 0.0))
                path.close()
                path.fill()
                wwdcPath.append(path)
            }
            return createWWDCBackingLayer(with: wwdcPath.cgPath)
        }
        return CALayer()
    }
    
    // Create a mask in the shape of WWDC
    private func createWWDCBackingLayer(with mask: CGPath) -> CALayer {
        // Create WWDC Mask
        let bezierMask = CAShapeLayer()
        let maskSize = CGSize(width: mask.boundingBox.width, height: mask.boundingBox.height)
        bezierMask.frame = CGRect(x: view.bounds.midX - (0.5 * maskSize.width), y: view.bounds.midY - (0.5 * maskSize.height) + 40, width: maskSize.width, height: maskSize.height)
        bezierMask.fillColor = UIColor.white.cgColor
        bezierMask.path = mask
        bezierMask.isGeometryFlipped = true
        
        // Create emitter
        let emitter = CAEmitterLayer()
        emitter.frame = view.bounds
        
        emitter.emitterPosition = CGPoint(x: view.center.x, y: view.center.y + 40)
        emitter.emitterShape = .rectangle
        emitter.emitterSize = CGSize(width: maskSize.width, height: maskSize.height)
        
        let cell = CAEmitterCell()
        cell.lifetime = 3000.0
        cell.scale = 0.1
        cell.scaleRange = 0.09
        cell.contents = UIImage(named: "star-circle.png")?.cgImage
        cell.birthRate = 1
        
        emitter.emitterCells = [cell]
        emitter.backgroundColor = UIColor.clear.cgColor
        
        emitter.mask = bezierMask
        
        return emitter
    }
}


// MARK: - Cornfield
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

// MARK: - Cornstalks
class CornstalkSnapBehavior: UISnapBehavior {
    var origin = CGPoint(x: 0, y: 0)
}

class CornstalkImageView: UIImageView {
    
    static let imageNames = ["cs1", "cs2", "cs3", "cs4", "cs5", "cs6", "cs7", "cs8", "cs9", "cs10", "cs11"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImage(named: CornstalkImageView.imageNames.randomElement() ?? "")
        contentMode = .scaleToFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

// MARK: - Extensions
extension UIColor {
    // Credit: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values/36009030#36009030
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    // Credit: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values/36009030#36009030
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
    }
}



// Present the view controller in the Live View window
let vc = DakotaViewController()
PlaygroundPage.current.liveView = vc
