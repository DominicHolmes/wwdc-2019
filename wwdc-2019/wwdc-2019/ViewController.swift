//
//  ViewController.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/15/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit
//import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let button = UIButton(frame: CGRect(x: 20, y: 100, width: 50, height: 50))
        button.sendActions(for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(spawnMeteors), for: .touchUpInside)
        button.backgroundColor = UIColor.darkGray
        view.addSubview(button)
    }

    func listenVolumeButton(){
        
        /*let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("audio session refused to start")
        }
        audioSession.addObserver(self, forKeyPath: "outputVolume",
                                 options: NSKeyValueObservingOptions.new, context: nil)*/
    }

    @objc func spawnMeteors() {
        listenVolumeButton()
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
        
        for i in 0...500 {
            let xoff = CGFloat.random(in: -200.0...200.0)
            let yoff = CGFloat.random(in: -200.0...200.0)
            let toff = Double.random(in: 0.0...6.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + toff) {
                self.addMeteor(at: CGPoint(x: 300 + xoff, y: 300 + yoff))
            }
        }
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

