//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MeteorViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        self.view.frame = CGRect(x: 0, y: 0, width: 700, height: 300)

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
    
    @objc func spawnMeteors() {
        print("did this")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addMeteor(at: CGPoint(x: 300, y: 300))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.addMeteor(at: CGPoint(x: 400, y: 400))
            self.addMeteor(at: CGPoint(x: 220, y: 400))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.addMeteor(at: CGPoint(x: 220, y: 400))
        }
        
        //for i in 0...30 {
            
        //}
    }
    
    
    
    func addMeteor(at origin: CGPoint) {
        let r: CGFloat = 200.0
        let pi = CGFloat.pi
        let startPoint = CGPoint(x: origin.x + r * cos(1.35 * pi), y: origin.y + r * sin(1.35 * pi))
        
        
        let path = UIBezierPath()
        
        path.move(to: startPoint)
        path.addArc(withCenter: origin, radius: r, startAngle: 1.35 * pi, endAngle: 1.1 * pi, clockwise: false)
        
        let meteor = CAShapeLayer()
        meteor.path = path.cgPath
        meteor.lineCap = .round
        meteor.strokeColor = UIColor.white.cgColor
        meteor.lineWidth = 1.0
        meteor.strokeStart = 0.0
        meteor.strokeEnd = 1.0
        meteor.opacity = 0.0
        
        let strokeStartAnimation = CABasicAnimation(
            keyPath: "strokeStart")
        strokeStartAnimation.fromValue = -0.5
        strokeStartAnimation.toValue = 0.5
        strokeStartAnimation.duration = 0.7
        
        let strokeEndAnimation = CABasicAnimation(
            keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        strokeEndAnimation.duration = 0.7
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 0.6, 0.7, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.3, 0.7, 1.0]
        opacityAnimation.duration = 0.7
        
        self.view.layer.addSublayer(meteor)
        
        meteor.add(strokeStartAnimation, forKey: "meteorAnimation")
        meteor.add(strokeEndAnimation, forKey: "meteorEndAnimation")
        meteor.add(opacityAnimation, forKey: "meteorOpacityAnimation")
    }
}
// Present the view controller in the Live View window
let vc = MeteorViewController()
vc.view.frame.size = CGSize(width: 200, height: 400)
PlaygroundPage.current.liveView = vc
