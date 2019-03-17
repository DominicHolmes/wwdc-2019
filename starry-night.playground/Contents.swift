import UIKit
import PlaygroundSupport
import AVFoundation

extension CGPoint {
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        return CGFloat(bearingRadians)
    }
}

class MeteorViewController : UIViewController {
    
    var skyView: UIView?
    
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
        
        skyView = UIView(frame: view.bounds)
        view.addSubview(skyView!)
        
        let emitterLayer = CAEmitterLayer()
        
        emitterLayer.emitterPosition = CGPoint(x: view.center.x, y: view.center.y)
        emitterLayer.emitterShape = .rectangle
        emitterLayer.emitterSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        emitterLayer.allowsGroupOpacity
        
        let cell = CAEmitterCell()
        print("2")
        cell.lifetime = Float.greatestFiniteMagnitude
        cell.velocity = 0
        cell.scale = 0.1
        cell.scaleRange = 0.09
        cell.contents = UIImage(named: "star-circle.png")!.cgImage
        cell.birthRate = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            cell.birthRate = 0
            emitterLayer.emitterCells = [cell]
            print("1")
        }
        
        emitterLayer.emitterCells = [cell]
        
        skyView?.layer.addSublayer(emitterLayer)
        
        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 50, height: 20)
        label.text = "Hello world"
        label.textColor = .white
        skyView?.addSubview(label)
        
        
        
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        button.sendActions(for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(rotateStars), for: .touchUpInside)
        button.backgroundColor = UIColor.darkGray
        skyView!.addSubview(button)
        
    }
    
    @objc func rotateStars() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat(.pi * 2.0)
        rotateAnimation.duration = 360.0
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        print("Doing the animation!")
        
        skyView!.layer.add(rotateAnimation, forKey: nil)
    }
}
// Present the view controller in the Live View window
let vc = MeteorViewController()
PlaygroundPage.current.liveView = vc

