import UIKit
import PlaygroundSupport
import AVFoundation

class MeteorViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 50, height: 20)
        label.text = ""
        label.textColor = .white
        
        view.addSubview(label)
        self.view = view
        
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        button.sendActions(for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(spawnMeteors), for: .touchUpInside)
        button.backgroundColor = UIColor.darkGray
        view.addSubview(button)
    }
    
    func listenVolumeButton(){
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("audio session refused to start")
        }
        audioSession.addObserver(self, forKeyPath: "outputVolume",
                                 options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    @objc func spawnMeteors() {
        
        for _ in 0...10 {
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
        let params = MeteorParams(radius: 300,
                                  startAngleFuzz: 0.0,
                                  endAngleFuzz: 0.0,
                                  origin: CGPoint(x: 300, y: 300))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spawnMeteor(with: params)
        }
    }
    
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
// Present the view controller in the Live View window
let vc = MeteorViewController()
vc.view.frame.size = CGSize(width: 700, height: 400)
PlaygroundPage.current.liveView = vc

