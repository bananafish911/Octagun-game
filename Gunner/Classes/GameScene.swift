//
//  GameScene.swift
//  Gunner
//
//  Created by Victor on 7/9/16.
//  Copyright (c) 2016 Bananaapps. All rights reserved.
//

import SpriteKit
import AudioToolbox

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    
    // category masks:
    let cPlayer: UInt32 =    0x0001
    let cBullet: UInt32 =    0x0010
    let cEnemy: UInt32 =     0x0100
    
    let cTest: UInt32 =      0x1000
    
    // player
    var player = Player()
    var gravityField = SKFieldNode.radialGravityField()
    
    // MARK: - Methods
    
    override func didMoveToView(view: SKView) {
        self.size = CGSizeMake(640, 640)
        
        self.addPlayer()
        
        // setup physics, gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        gravityField.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        gravityField.categoryBitMask = cEnemy
        gravityField.strength = 0.1 //measures the acceleration of the field in meters per second squared
        addChild(gravityField)
    }
    
    func addPlayer() {
        let texture = SKTexture(imageNamed: "sentryGun")
        texture.filteringMode = .Nearest
        player = Player(texture: texture)
        player.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        player.setScale(1.0)
        // physics body
        player.physicsBody = SKPhysicsBody(texture: texture, size: player.size)
        player.physicsBody?.dynamic = false
        player.physicsBody?.categoryBitMask = cPlayer
        player.physicsBody?.contactTestBitMask = cEnemy
        player.physicsBody?.collisionBitMask = cEnemy
        player.physicsBody?.fieldBitMask = cPlayer
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.mass = 0
        self.addChild(player)
    }
    
    func burstBullet(directionLocation: CGPoint) {
        let bullet = Bullet(imageNamed: "bullet")
        bullet.setScale(1.0)
        // physics body
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.categoryBitMask = cBullet
        bullet.physicsBody?.contactTestBitMask = cEnemy | cBullet
        bullet.physicsBody?.collisionBitMask = cEnemy | cBullet
        bullet.physicsBody?.fieldBitMask = cBullet
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.mass = 1
        bullet.name = "bullet"
        bullet.zRotation = player.zRotation
        bullet.position = player.position
        bullet.zPosition = -1
        
        self.addChild(bullet)
//        //
        let angleInRadians = Float(getAngleAxisRadians(directionLocation))
        let dx = CGFloat(cosf(angleInRadians + Float(M_PI_2)))
        let dy = CGFloat(sinf(angleInRadians + Float(M_PI_2)))
        let scale: CGFloat = 10000
        let vector = CGVector(dx: dx * scale, dy: dy * scale)
        
        bullet.physicsBody?.applyForce(vector)
    }
    
    func addEnemy() {
        let enemy = Enemy(imageNamed: "enemy")
        enemy.setScale(CGFloat.random(0.5, 1.5))
        // physics body
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.categoryBitMask = cEnemy
        enemy.physicsBody?.contactTestBitMask = cPlayer | cBullet | cEnemy
        enemy.physicsBody?.collisionBitMask = cPlayer | cBullet | cEnemy
        enemy.physicsBody?.fieldBitMask = cEnemy
        enemy.physicsBody?.usesPreciseCollisionDetection = true
        enemy.physicsBody?.mass = enemy.xScale
        enemy.name = "enemy"
        let randomPosition = CGPoint(x: Int.random(0, 640), y: Int.random(0, 1) == 0 ? -50 : 690)
        // TODO: random
        enemy.position = randomPosition
        self.addChild(enemy)
        
//        let vector = CGVector(dx: player.position.x * enemy.xScale, dy: player.position.y * enemy.xScale)
//        
//        enemy.physicsBody?.applyForce(vector)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if player.containsPoint(location) {
                self.addEnemy()
                return
            }
            
            
            let rotateAction = SKAction.rotateToAngle(getAngleAxisRadians(location), duration: 0.05, shortestUnitArc: true)
            player.runAction(rotateAction)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if player.containsPoint(location) {
                return
            }
            
            let rotateAction = SKAction.rotateToAngle(getAngleAxisRadians(location), duration: 0.05, shortestUnitArc: true)
            player.runAction(rotateAction)
            
            self.burstBullet(location)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if player.containsPoint(location) {
                return
            }
            
            self.burstBullet(location)
        }
    }
    
    
    
    
    
    var updateTime: Double = 0
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if currentTime - updateTime > 1 {
            addEnemy()
            updateTime = currentTime
        }
        
        self.enumerateChildNodesWithName("bullet") { (node, stop) in
            if node.position.x > 640 || node.position.x < 0 || node.position.y > 640 || node.position.y < 0 {
                node.removeFromParent()
            }
        }
    }
    
    
    
    
    func getAngleAxisRadians(point: CGPoint) -> CGFloat {
        let relativeTouch = CGPoint(x: point.x - player.position.x,
                                    y: point.y - player.position.y)
        let radians = atan2(-relativeTouch.x, relativeTouch.y)
        print("relative touch:\(relativeTouch)")
        print("radains: \(radians)")
        
        return radians
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (cBullet | cEnemy) {
            // bullet and enemy contact
            var bullet = SKPhysicsBody()
            var enemy = SKPhysicsBody()
            if contact.bodyA.categoryBitMask == cBullet {
                bullet = contact.bodyA
                enemy = contact.bodyB
            } else {
                bullet = contact.bodyB
                enemy = contact.bodyA
            }
            
            var hit:CGFloat = 0.5
            
            if let enemyNode = enemy.node as? Enemy {
                hit = 0.5 * (1.5 / enemyNode.physicsBody!.mass)
                enemyNode.healthPower = enemyNode.healthPower - hit
            }
            
            if let bulletNode = bullet.node as? Bullet {
                bulletNode.healthPower = bulletNode.healthPower - hit
            }
        }
        
        if (contact.bodyA.categoryBitMask == cPlayer) || (contact.bodyB.categoryBitMask == cPlayer) {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }

    }
}
