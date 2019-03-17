import UIKit
import PlaygroundSupport
import AVFoundation

class MeteorViewController : UIViewController {
    
    // Gradient layer on base view (no rotation)
    var skyGradient: CAGradientLayer!
    
    // Rotating skybox
    var skyView: UIView!
    // Constellation layer inside skyView
    var constellationLayer: CAEmitterLayer!
    
    
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
        
        // Begin skybox rotation
        rotateStars()
        
        
        // Button for testing
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        button.sendActions(for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(rotateStars), for: .touchUpInside)
        button.backgroundColor = UIColor.darkGray
        skyView.addSubview(button)
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
    
    func createConstellationLayer() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: view.center.y)
        emitter.emitterShape = .rectangle
        emitter.emitterSize = CGSize(width: view.frame.size.width * 2, height: view.frame.size.height * 2)
        emitter.allowsGroupOpacity
        let cell = CAEmitterCell()
        cell.lifetime = 2000.0
        //cell.velocity = 0
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

