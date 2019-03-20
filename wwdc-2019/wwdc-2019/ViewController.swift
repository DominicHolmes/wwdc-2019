//
//  ViewController.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/15/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit
//import AVFoundation
//import MediaPlayer.MPVolumeView

class ViewController: UIViewController {
    
    var skyView: UIView!
    var skyGradient: CAGradientLayer!
    var constellationLayer: CAEmitterLayer!
    var moonLayer: CAShapeLayer!
    var firefliesLayers: (CAEmitterLayer, CAEmitterLayer)!
    var wwdcLayer: CAEmitterLayer!
    
    // Meteor animations repeat every 10 seconds
    // They are visible if the bool is true
    // The frequency multiplier changes with the system volume
    //var meteorLoop: (Bool, Float) = (true, 0.0)
    // TODO: change this
    var meteorLoop: (Bool, Float) = (true, 0.5)
    var meteorTimer: Timer?
    
    let notificationCenter = NotificationCenter.default
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 50, height: 20)
        label.text = ""
        label.textColor = .white
        view.addSubview(label)
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
        
        // Create stars with an emitter layer
        constellationLayer = createConstellationLayer()
        skyView.layer.addSublayer(constellationLayer)
        fadeInConstellationLayer()
        
        // Add the moon
        moonLayer = createMoon()
        skyView.layer.addSublayer(moonLayer)
        
        // Begin skybox rotation
        rotateStars()
        
        // Create fireflies
        firefliesLayers = (createFirefliesLayer(), createFirefliesLayer())
        view.layer.addSublayer(firefliesLayers.0)
        
        view.layer.addSublayer(createWWDC())
        
        //createMountain()
        createCornfield()
        
        // Add fireflies on top of corn
        view.layer.addSublayer(firefliesLayers.1)
        
        // Create WWDC layer
        //wwdcLayer = createLogoLayer()
        //view.layer.addSublayer(wwdcLayer)
        /*for each in createWWDC() {
            view.layer.addSublayer(each)
        }*/
        
        // Button for testing
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        button.sendActions(for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(spawnMeteors), for: .touchUpInside)
        button.backgroundColor = UIColor.darkGray
        skyView.addSubview(button)
        
        // Add pan gesture for manipulating the stars
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(self.handlePanGesture(_:))))
        self.view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start listening to volume change events
        notificationCenter.addObserver(self,
                                       selector: #selector(systemVolumeDidChange),
                                       name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                       object: nil
        )
        
        meteorTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(spawnMeteors), userInfo: nil, repeats: true)
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
    @objc func systemVolumeDidChange(notification: NSNotification) {
        print(notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float as Any)
        if let newVolume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            meteorLoop.1 = newVolume
            meteorLoop.0 = (newVolume > 0)
        }
    }
    
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
    
    @objc func rotateStars() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat(.pi * 2.0)
        //rotateAnimation.duration = 1000.0
        rotateAnimation.duration = 500.0
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        skyView.layer.add(rotateAnimation, forKey: "skyboxRotation")
    }
    
    // MARK: - Moon
    func createMoon() -> CAShapeLayer {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 300, y: 300))
        path.addArc(withCenter: view.center, radius: 50.0, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        let moon = CAShapeLayer()
        moon.path = path.cgPath
        moon.frame = CGRect(x: 300, y: 500, width: 50, height: 50)
        moon.fillColor = UIColor.green.cgColor
        
        return moon
    }
    
    func mtnPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        let ratio = self.view.bounds.width / 2152.0
        return CGPoint(x: x * ratio, y: y * ratio)
    }
    
    func createCornfield() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: view.bounds.height - 310, width: view.bounds.width, height: 320))
        imageView.contentMode = .topLeft
        imageView.image = UIImage(named: "cornfield")
        view.addSubview(imageView)
    }
    
    // MARK: - Mountain
    func createMountain() {
        
        let ratio = self.view.bounds.width / 2152.0
        print(ratio)
        
        // Base mountain
        let bezierPath = UIBezierPath()
        bezierPath.move(to: mtnPoint(x: 0, y: 1154.2))
        bezierPath.addCurve(to: mtnPoint(x: 505.49, y: 996.47), controlPoint1: mtnPoint(x: 0, y: 1154.2), controlPoint2: mtnPoint(x: 412.74, y: 1028.94))
        bezierPath.addCurve(to: mtnPoint(x: 877.65, y: 842.21), controlPoint1: mtnPoint(x: 598.24, y: 963.99), controlPoint2: mtnPoint(x: 877.65, y: 842.21))
        bezierPath.addCurve(to: mtnPoint(x: 995.9, y: 823.66), controlPoint1: mtnPoint(x: 877.65, y: 842.21), controlPoint2: mtnPoint(x: 947.21, y: 812.06))
        bezierPath.addCurve(to: mtnPoint(x: 1138.51, y: 842.21), controlPoint1: mtnPoint(x: 1044.6, y: 835.25), controlPoint2: mtnPoint(x: 1138.51, y: 842.21))
        bezierPath.addCurve(to: mtnPoint(x: 1303.14, y: 842.21), controlPoint1: mtnPoint(x: 1138.51, y: 842.21), controlPoint2: mtnPoint(x: 1276.47, y: 845.69))
        bezierPath.addCurve(to: mtnPoint(x: 1623.13, y: 983.71), controlPoint1: mtnPoint(x: 1329.8, y: 838.73), controlPoint2: mtnPoint(x: 1400.53, y: 896.72))
        bezierPath.addCurve(to: mtnPoint(x: 2152.96, y: 1178.56), controlPoint1: mtnPoint(x: 1845.73, y: 1070.7), controlPoint2: mtnPoint(x: 2152.96, y: 1178.56))
        bezierPath.addLine(to: mtnPoint(x: 2226, y: 1202.91))
        bezierPath.addLine(to: mtnPoint(x: 2226, y: 1668))
        bezierPath.addLine(to: mtnPoint(x: 0, y: 1668))
        bezierPath.addLine(to: mtnPoint(x: 0, y: 1154.2))
        bezierPath.close()
        
        let mountainBase = CAShapeLayer()
        mountainBase.frame = view.bounds
        mountainBase.path = bezierPath.cgPath
        mountainBase.fillColor = UIColor.white.cgColor
        
        // Shadow part of the mountain
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: mtnPoint(x: 511.81, y: 996.12))
        bezier2Path.addCurve(to: mtnPoint(x: 887.89, y: 840.41), controlPoint1: mtnPoint(x: 605.54, y: 963.34), controlPoint2: mtnPoint(x: 887.89, y: 840.41))
        bezier2Path.addCurve(to: mtnPoint(x: 1007.39, y: 821.68), controlPoint1: mtnPoint(x: 887.89, y: 840.41), controlPoint2: mtnPoint(x: 958.19, y: 809.97))
        bezier2Path.addCurve(to: mtnPoint(x: 1145, y: 840), controlPoint1: mtnPoint(x: 1056.6, y: 833.39), controlPoint2: mtnPoint(x: 1145, y: 840))
        bezier2Path.addLine(to: mtnPoint(x: 1307, y: 842))
        bezier2Path.addCurve(to: mtnPoint(x: 1299.12, y: 852.12), controlPoint1: mtnPoint(x: 1307, y: 842), controlPoint2: mtnPoint(x: 1313.18, y: 846.27))
        bezier2Path.addCurve(to: mtnPoint(x: 1221.79, y: 879.05), controlPoint1: mtnPoint(x: 1285.06, y: 857.97), controlPoint2: mtnPoint(x: 1227.65, y: 879.05))
        bezier2Path.addCurve(to: mtnPoint(x: 1123.38, y: 894.27), controlPoint1: mtnPoint(x: 1215.93, y: 879.05), controlPoint2: mtnPoint(x: 1199.53, y: 888.41))
        bezier2Path.addCurve(to: mtnPoint(x: 1056.6, y: 897.78), controlPoint1: mtnPoint(x: 1047.23, y: 900.12), controlPoint2: mtnPoint(x: 1070.66, y: 897.78))
        bezier2Path.addCurve(to: mtnPoint(x: 1021.45, y: 903.63), controlPoint1: mtnPoint(x: 1042.54, y: 897.78), controlPoint2: mtnPoint(x: 1021.45, y: 897.78))
        bezier2Path.addCurve(to: mtnPoint(x: 1137.44, y: 957.49), controlPoint1: mtnPoint(x: 1021.45, y: 909.49), controlPoint2: mtnPoint(x: 1053.08, y: 927.05))
        bezier2Path.addCurve(to: mtnPoint(x: 1217.4, y: 988.06), controlPoint1: mtnPoint(x: 1167.23, y: 968.24), controlPoint2: mtnPoint(x: 1194.53, y: 978.84))
        bezier2Path.addCurve(to: mtnPoint(x: 1286.23, y: 1017.19), controlPoint1: mtnPoint(x: 1259.27, y: 1004.95), controlPoint2: mtnPoint(x: 1286.23, y: 1017.19))
        bezier2Path.addCurve(to: mtnPoint(x: 1370.58, y: 1061.68), controlPoint1: mtnPoint(x: 1286.23, y: 1017.19), controlPoint2: mtnPoint(x: 1349.5, y: 1046.46))
        bezier2Path.addCurve(to: mtnPoint(x: 1417.45, y: 1113.19), controlPoint1: mtnPoint(x: 1391.67, y: 1076.9), controlPoint2: mtnPoint(x: 1417.45, y: 1102.66))
        bezier2Path.addCurve(to: mtnPoint(x: 1360.04, y: 1164.71), controlPoint1: mtnPoint(x: 1417.45, y: 1123.73), controlPoint2: mtnPoint(x: 1433.85, y: 1151.83))
        bezier2Path.addCurve(to: mtnPoint(x: 1167.9, y: 1164.71), controlPoint1: mtnPoint(x: 1286.23, y: 1177.58), controlPoint2: mtnPoint(x: 1235.85, y: 1168.22))
        bezier2Path.addCurve(to: mtnPoint(x: 887.89, y: 1225.58), controlPoint1: mtnPoint(x: 1099.95, y: 1161.19), controlPoint2: mtnPoint(x: 958.19, y: 1171.73))
        bezier2Path.addCurve(to: mtnPoint(x: 743.79, y: 1348.51), controlPoint1: mtnPoint(x: 817.6, y: 1279.44), controlPoint2: mtnPoint(x: 803.54, y: 1309.88))
        bezier2Path.addCurve(to: mtnPoint(x: 569.22, y: 1416.41), controlPoint1: mtnPoint(x: 684.03, y: 1387.15), controlPoint2: mtnPoint(x: 569.22, y: 1416.41))
        bezier2Path.addCurve(to: mtnPoint(x: 278.67, y: 1436.32), controlPoint1: mtnPoint(x: 569.22, y: 1416.41), controlPoint2: mtnPoint(x: 386.45, y: 1453.88))
        bezier2Path.addCurve(to: mtnPoint(x: 1, y: 1416.41), controlPoint1: mtnPoint(x: 170.88, y: 1418.76), controlPoint2: mtnPoint(x: 1, y: 1416.41))
        bezier2Path.addLine(to: mtnPoint(x: 1, y: 1155.34))
        bezier2Path.addCurve(to: mtnPoint(x: 511.81, y: 996.12), controlPoint1: mtnPoint(x: 1, y: 1155.34), controlPoint2: mtnPoint(x: 418.08, y: 1028.9))
        bezier2Path.close()
        
        let mountainShadow = CAShapeLayer()
        mountainShadow.frame = view.bounds
        mountainShadow.path = bezier2Path.cgPath
        mountainShadow.fillColor = UIColor.lightGray.cgColor
        
        view.layer.addSublayer(mountainBase)
        view.layer.addSublayer(mountainShadow)
    }
    
    // MARK: - Meteor spawning logic
    @objc func spawnMeteors() {
        
        guard meteorLoop.0 == true && meteorLoop.1 > 0 else { return }
        
        let widthOffset = view.bounds.width / 2.0
        
        for _ in 0 ... Int(20 * meteorLoop.1) {
            
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
        strokeStartAnimation.duration = 1.0
        
        let strokeEndAnimation = CABasicAnimation(
            keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        strokeEndAnimation.duration = 1.0
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 1.0, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.5, 1.0]
        opacityAnimation.duration = 1.3
        
        // Add the meteor gradient to the view
        view.layer.addSublayer(meteorGradient)
        
        // Animate the meteor mask
        meteorMask.add(strokeStartAnimation, forKey: "meteorAnimation")
        meteorMask.add(strokeEndAnimation, forKey: "meteorEndAnimation")
        meteorMask.add(opacityAnimation, forKey: "meteorOpacityAnimation")
    }
}

//extension MeteorViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    // Get the Lux from camera buffer
//    // Credit: https://stackoverflow.com/questions/22753165/detecting-if-iphone-is-in-a-dark-room/22836060#22836060
//    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        let metadataDict = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
//        let metadata = metadataDict as? [AnyHashable : Any]
//        let exifMetadata = (metadata![kCGImagePropertyExifDictionary as String]) as? [AnyHashable : Any]
//        let brightnessValue: Float = (exifMetadata?[kCGImagePropertyExifBrightnessValue as String] as? NSNumber)?.floatValue ?? 0.0
//        print(brightnessValue)
//    }
//}

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

