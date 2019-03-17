import UIKit
import PlaygroundSupport
import AVFoundation

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
        
        // Add gradient to sky
        createSkyGradient()
        
        skyView = UIView(frame: view.bounds)
        view.addSubview(skyView!)
        
        let emitterLayer = CAEmitterLayer()
        
        emitterLayer.emitterPosition = CGPoint(x: view.center.x, y: view.center.y)
        emitterLayer.emitterShape = .rectangle
        emitterLayer.emitterSize = CGSize(width: view.frame.size.width * 2, height: view.frame.size.height * 2)
        emitterLayer.allowsGroupOpacity
        
        let cell = CAEmitterCell()
        print("2")
        //cell.lifetime = Float.greatestFiniteMagnitude
        cell.lifetime = 2000.0
        cell.velocity = 0
        cell.scale = 0.1
        cell.scaleRange = 0.09
        cell.contents = UIImage(named: "star-circle.png")!.cgImage
        cell.birthRate = 1
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
         emitterLayer.birthRate = 0
         print("1")
         }*/
        
        emitterLayer.emitterCells = [cell]
        
        skyView?.layer.addSublayer(emitterLayer)
        
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        button.sendActions(for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(rotateStars), for: .touchUpInside)
        button.backgroundColor = UIColor.darkGray
        skyView!.addSubview(button)
        
    }
    
    func createSkyGradient() {
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(rgb: 0x000428, a: 1.0).cgColor, UIColor(rgb: 0x004E92, a: 1.0).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        view.layer.addSublayer(gradient)
    }
    
    @objc func rotateStars() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat(.pi * 2.0)
        rotateAnimation.duration = 1000.0
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        print("Doing the animation!")
        
        skyView!.layer.add(rotateAnimation, forKey: nil)
    }
}

// MARK: - Extensions
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
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

