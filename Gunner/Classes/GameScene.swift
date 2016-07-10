//
//  GameScene.swift
//  Gunner
//
//  Created by Victor on 7/9/16.
//  Copyright (c) 2016 Bananaapps. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    
    // category masks:
    let cPlayer: UInt32 =    0x0001
    let cBullet: UInt32 =    0x0010
    let cEnemy: UInt32 =     0x0100
    
    // player
    lazy var player: Player = {
        let node = self.childNodeWithName("player") as! Player
        return node
    }()
    lazy var cannon: SKSpriteNode = {
        let node = self.player.childNodeWithName("cannon") as! SKSpriteNode
        return node
    }()
    
    // MARK: - Methods
    
    override func didMoveToView(view: SKView) {
        self.size = CGSizeMake(640, 640)
        player.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        
        player.physicsBody?.categoryBitMask = cPlayer
        
        // Making self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func burstBullet(directionLocation: CGPoint) {
        let bullet = Bullet(imageNamed: "bullet")
        bullet.setScale(1.0)
        // physics body
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody?.categoryBitMask = cBullet
        bullet.physicsBody?.dynamic = true
        bullet.physicsBody?.contactTestBitMask = cEnemy
        bullet.physicsBody?.collisionBitMask = cEnemy
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        bullet.name = "bullet"
        bullet.zRotation = cannon.zRotation
        bullet.position = cannon.convertPoint(cannon.position, toNode: self)
        
        self.addChild(bullet)
        //
        let angleInRadians = Float(getAngleAxisRadians(directionLocation))
        let dx = CGFloat(cosf(angleInRadians + Float(M_PI_2)))
        let dy = CGFloat(sinf(angleInRadians + Float(M_PI_2)))
        let scale: CGFloat = 44
        let vector = CGVector(dx: dx * scale, dy: dy * scale)
        
        bullet.physicsBody?.applyForce(vector)
    }
    
    func addEnemy() {
        let enemy = Enemy(imageNamed: "enemy")
        enemy.setScale(CGFloat.random(0.3, 1))
        // physics body
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
        enemy.physicsBody?.categoryBitMask = cEnemy
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.contactTestBitMask = cPlayer | cBullet | cEnemy
        enemy.physicsBody?.collisionBitMask = cPlayer | cBullet | cEnemy
        enemy.physicsBody?.usesPreciseCollisionDetection = true
        
        enemy.name = "enemy"
        let randomPosition = CGPoint(x: 0, y: 0)
        // TODO: random
        enemy.position = randomPosition
        self.addChild(enemy)
        
        let vector = CGVector(dx: player.position.x * enemy.xScale, dy: player.position.y * enemy.xScale)
        
        enemy.physicsBody?.applyForce(vector)
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
    
    
    
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
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
            
            if let enemyNode = enemy.node as? Enemy {
                enemyNode.healthPower = enemyNode.healthPower - 10
            }
            
            if let bulletNode = bullet.node as? Bullet {
                bulletNode.healthPower = bulletNode.healthPower / 2
            }
        }

    }
}
