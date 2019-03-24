//
//  Fireflies.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/20/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit
import CoreText

extension DakotaViewController {
    func createFirefliesLayer() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: view.bounds.maxY + 5)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.birthRate = 0.0
        
        
        let cell = CAEmitterCell()
        cell.lifetime = 10
    
        cell.contents = UIImage(named: "firefly.png")!.cgImage
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
        cell.contents = UIImage(named: "star-circle.png")!.cgImage
        cell.birthRate = 1
        
        emitter.emitterCells = [cell]
        emitter.backgroundColor = UIColor.clear.cgColor

        emitter.mask = bezierMask
        
        return emitter
    }
}
