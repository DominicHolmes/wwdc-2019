//
//  Fireflies.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/20/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit
import CoreText

extension ViewController {
    func createFirefliesLayer() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: view.bounds.maxY + 5)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        let cell = CAEmitterCell()
        cell.lifetime = 10
    
        cell.contents = UIImage(named: "firefly.png")!.cgImage
        cell.birthRate = 4
        
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
    
    func createWWDC() -> CALayer {
        //Credit: https://stackoverflow.com/questions/11172207/get-path-to-trace-out-a-character-in-an-ios-uifont
        let font = UIFont(name: "AvenirNext-DemiBold", size: 200)!
        
        var unichars = [UniChar]("WWDC".utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
        if gotGlyphs {
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
            return createFirefliesBackingLayer(with: wwdcPath.cgPath)
        }
        return CALayer()
    }
    
    private func createFirefliesBackingLayer(with mask: CGPath) -> CALayer {
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
        cell.lifetime = 10
        
        cell.contents = UIImage(named: "firefly.png")!.cgImage
        cell.birthRate = 500
        
        // Emission angles and acceleration
        cell.emissionLongitude = 0.5 * .pi
        cell.emissionRange = .pi * 0.3
        cell.xAcceleration = CGFloat.random(in: -1 ... 1)
        cell.yAcceleration = CGFloat.random(in: -1 ... 1)
        
        cell.velocity = 0
        cell.velocityRange = 5
        
        // Scale
        cell.scale = 0.5
        cell.scaleRange = 0.1
        cell.scaleSpeed = -0.5 / CGFloat(cell.lifetime)
        
        // Alpha
        cell.alphaSpeed = -1.0 / cell.lifetime
        
        emitter.emitterCells = [cell]
        emitter.backgroundColor = UIColor.clear.cgColor

        emitter.mask = bezierMask
        
        return emitter
    }
}
