//
//  Player.swift
//  Gunner
//
//  Created by Victor on 7/10/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit

class Player: BaseNode {
    
    // MARK: - Properties
    
    /// May be between 0 and 100
    override var healthPower: Int {
        didSet {
            self.alpha = 1.0
            self.updateHPIndicator()
        }
    }
    private var hpIndicator = SKShapeNode()
    lazy var turretBody: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "Turret-body")
        texture.filteringMode = .Nearest
        let node = SKSpriteNode(texture: texture, size: texture.size())
        return node
    }()
    lazy var turretGun: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "Turret-gun")
        texture.filteringMode = .Nearest
        let node = SKSpriteNode(texture: texture, size: texture.size())
        return node
    }()
    lazy var turretGunTube: SKSpriteNode = {
        let texture = SKTexture(imageNamed: "Turret-tube")
        texture.filteringMode = .Nearest
        let node = SKSpriteNode(texture: texture, size: texture.size())
        return node
    }()
    
    // MARK: - Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        let texture = SKTexture(imageNamed: "Player-body")
        super.init(texture: texture, color: UIColor.appRedColor(), size: texture.size())
        
        // components
        self.addChild(turretBody)
        turretBody.addChild(turretGun)
        turretGun.addChild(turretGunTube)
        turretGunTube.position = CGPoint(x: 0, y: 24)
    }
    
    private func updateHPIndicator() {
        hpIndicator.removeFromParent()
        
        // hidden when full
        if self.healthPower < 100 {
            let angle = self.hpToRadians(healthPower)
            let center = CGPointMake(0, 0)
            
            let bezierPath = UIBezierPath(arcCenter: center, radius: self.size.height / 6, startAngle: 0, endAngle: angle, clockwise: false)
            bezierPath.addLineToPoint(center)
            bezierPath.closePath()
            
            hpIndicator = SKShapeNode(path: bezierPath.CGPath)
            hpIndicator.fillColor = UIColor.appRedColor().colorWithAlphaComponent(0.5)
            hpIndicator.strokeColor = UIColor.clearColor()
            hpIndicator.zPosition = 1
            hpIndicator.zRotation = CGFloat(M_PI_2)
            
            self.addChild(hpIndicator)
        }
    }
    
    private func hpToRadians(hp: Int) -> CGFloat {
        return (2 * CGFloat(M_PI)) * (CGFloat(hp) / 100)
    }
    
    override func configurePhysics(bitmask: UInt32, enemyBitmask: UInt32, mass: CGFloat) {
        super.configurePhysics(bitmask, enemyBitmask: enemyBitmask, mass: mass)
        self.physicsBody?.pinned = true
        self.physicsBody?.dynamic = false
        // tube physics body
        turretGunTube.physicsBody = SKPhysicsBody(texture: turretGunTube.texture!, size: turretGunTube.size)
        turretGunTube.physicsBody?.pinned = true
        turretGunTube.physicsBody?.dynamic = false
        turretGunTube.physicsBody?.affectedByGravity = false
        turretGunTube.physicsBody?.categoryBitMask = bitmask
        turretGunTube.physicsBody?.contactTestBitMask = enemyBitmask
        turretGunTube.physicsBody?.collisionBitMask = enemyBitmask
        turretGunTube.physicsBody?.fieldBitMask = bitmask
        turretGunTube.physicsBody?.usesPreciseCollisionDetection = true
        turretGunTube.physicsBody?.mass = 0
    }
    
    func animateCannonShot() {
        // animate shot
        turretGun.runAction(SKAction.moveByX(0, y: -4, duration: 0.05)) {
            self.turretGun.runAction(SKAction.moveByX(0, y: 4, duration: 0.1))
        }
        turretGunTube.runAction(SKAction.moveByX(0, y: -2, duration: 0.05)) {
            self.turretGunTube.runAction(SKAction.moveByX(0, y: 2, duration: 0.1))
        }
    }
    
    func regenerate() {
        self.healthPower = 100
        // TODO: animated ??
    }
    
}