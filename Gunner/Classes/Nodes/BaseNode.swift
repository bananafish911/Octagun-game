//
//  BaseNode.swift
//  Gunner
//
//  Created by Victor on 7/15/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit

class BaseNode: SKSpriteNode {
    
    // MARK: - Properties
    
    /// May be between 0 and 100
    var healthPower: Int = 100 {
        didSet {
            if healthPower < 0 {
                healthPower = 0
            } else if healthPower > 100 {
                healthPower = 100
            }
            self.alpha = (CGFloat(healthPower) / 100) + 0.3
        }
    }
    
    /// Absolute value, min 0. Defines the damage level of another node on collision.
    lazy var damageForce: Int = {
        return Int(self.size.height)
    }()

    // MARK: - Methods
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func removeFromParent() {
        super.removeFromParent()
    }
    
    func hit(damagePercents: Int) {
        healthPower = healthPower - damagePercents
    }
    
    func configurePhysics(bitmask: UInt32, enemyBitmask: UInt32, mass: CGFloat) {
        // self physics body
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.pinned = false
        self.physicsBody?.dynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = bitmask
        self.physicsBody?.contactTestBitMask = enemyBitmask
        self.physicsBody?.collisionBitMask = enemyBitmask
        self.physicsBody?.fieldBitMask = bitmask
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.mass = mass
    }
    
    func clearBitMasks() {
        self.physicsBody?.categoryBitMask = 0x00
        self.physicsBody?.contactTestBitMask = 0x00
        self.physicsBody?.collisionBitMask = 0x00
        self.physicsBody?.fieldBitMask = 0x00
    }
}
