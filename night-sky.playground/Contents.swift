import UIKit
import PlaygroundSupport
import AVFoundation
import MediaPlayer.MPVolumeView

class MeteorViewController : UIViewController {
    
    var skyView: UIView!
    var skyGradient: CAGradientLayer!
    var constellationLayer: CAEmitterLayer!
    var moonLayer: CAShapeLayer!
    
    // Meteor animations repeat every 10 seconds
    // They are visible if the bool is true
    // The frequency multiplier changes with the system volume
    var meteorLoop: (Bool, Float) = (true, 0.0)
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
        
        createMountain()
        
        
        // Button for testing
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        button.sendActions(for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(spawnMeteors), for: .touchUpInside)
        button.backgroundColor = UIColor.darkGray
        skyView.addSubview(button)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start listening to volume change events
        notificationCenter.addObserver(self,
                                       selector: #selector(systemVolumeDidChange),
                                       name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                       object: nil
        )
        
        meteorTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(spawnMeteors), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop listening to volume change events
        notificationCenter.removeObserver(self)
        self.view.insertSubview(MPVolumeView(), aboveSubview: view)
        
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
        emitter.allowsGroupOpacity
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
        rotateAnimation.duration = 1000.0
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        skyView.layer.add(rotateAnimation, forKey: nil)
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
    
    // MARK: - Mountain
    func createMountain() -> CAShapeLayer {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 1154.2))
        bezierPath.addCurve(to: CGPoint(x: 505.49, y: 996.47), controlPoint1: CGPoint(x: 0, y: 1154.2), controlPoint2: CGPoint(x: 412.74, y: 1028.94))
        bezierPath.addCurve(to: CGPoint(x: 877.65, y: 842.21), controlPoint1: CGPoint(x: 598.24, y: 963.99), controlPoint2: CGPoint(x: 877.65, y: 842.21))
        bezierPath.addCurve(to: CGPoint(x: 995.9, y: 823.66), controlPoint1: CGPoint(x: 877.65, y: 842.21), controlPoint2: CGPoint(x: 947.21, y: 812.06))
        bezierPath.addCurve(to: CGPoint(x: 1138.51, y: 842.21), controlPoint1: CGPoint(x: 1044.6, y: 835.25), controlPoint2: CGPoint(x: 1138.51, y: 842.21))
        bezierPath.addCurve(to: CGPoint(x: 1303.14, y: 842.21), controlPoint1: CGPoint(x: 1138.51, y: 842.21), controlPoint2: CGPoint(x: 1276.47, y: 845.69))
        bezierPath.addCurve(to: CGPoint(x: 1623.13, y: 983.71), controlPoint1: CGPoint(x: 1329.8, y: 838.73), controlPoint2: CGPoint(x: 1400.53, y: 896.72))
        bezierPath.addCurve(to: CGPoint(x: 2152.96, y: 1178.56), controlPoint1: CGPoint(x: 1845.73, y: 1070.7), controlPoint2: CGPoint(x: 2152.96, y: 1178.56))
        bezierPath.addLine(to: CGPoint(x: 2226, y: 1202.91))
        bezierPath.addLine(to: CGPoint(x: 2226, y: 1668))
        bezierPath.addLine(to: CGPoint(x: 0, y: 1668))
        bezierPath.addLine(to: CGPoint(x: 0, y: 1154.2))
        bezierPath.close()
        
        let mountain = CAShapeLayer()
        mountain.frame = view.bounds
        mountain.path = bezierPath.cgPath
        mountain.fillColor = UIColor.white.cgColor
        
        view.layer.addSublayer(mountain)
    }
    
    // MARK: - Meteor spawning logic
    @objc func spawnMeteors() {
        
        guard meteorLoop.0 == true && meteorLoop.1 > 0 else { return }
        
        for _ in 0 ... Int(20 * meteorLoop.1) {
            let xoff = CGFloat.random(in: -200.0...200.0)
            let yoff = CGFloat.random(in: -200.0...200.0)
            let timeOff = Double.random(in: 0.0...10.0)
            let radius = CGFloat.random(in: 150...400)
            
            let params = MeteorParams(radius: radius,
                                      startAngleFuzz: CGFloat.random(in: -0.1...0.05),
                                      endAngleFuzz: CGFloat.random(in: -0.05...0.1),
                                      origin: CGPoint(x: 300 + xoff, y: 300 + yoff))
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


// Present the view controller in the Live View window
let vc = MeteorViewController()
PlaygroundPage.current.liveView = vc




