//
//  Player.swift
//  Gunner
//
//  Created by Victor on 7/10/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    
    lazy var hpIndicator: SKShapeNode = {
        let hp = SKShapeNode(circleOfRadius: self.size.width / 2)
        hp.fillColor = UIColor.redColor()
        hp.position = self.position
        self.addChild(hp)
        return hp
    }()
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}