//
//  CornstalkImageView.swift
//  wwdc-2019
//
//  Created by Dominic Holmes on 3/21/19.
//  Copyright © 2019 Dominic Holmes. All rights reserved.
//

import UIKit

class CornstalkImageView: UIImageView {
    
    static let imageNames = ["cs1", "cs2", "cs3", "cs4", "cs5", "cs6", "cs7", "cs8", "cs9", "cs10", "cs11"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImage(named: CornstalkImageView.imageNames.randomElement() ?? "")
        contentMode = .scaleToFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}
