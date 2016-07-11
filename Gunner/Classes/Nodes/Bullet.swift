//
//  Bullet.swift
//  Gunner
//
//  Created by Victor on 7/10/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit

class Bullet: SKSpriteNode {
    
    var healthPower: CGFloat = 1 {
        didSet {
            debugPrint("hp changed: \(healthPower)")
            self.alpha = healthPower
            if healthPower < 0.5 {
                self.removeFromParent()
            }
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}