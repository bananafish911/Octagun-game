//
//  GameScene.swift
//  Gunner
//
//  Created by Victor on 7/9/16.
//  Copyright (c) 2016 Bananaapps. All rights reserved.
//

import SpriteKit
import AudioToolbox
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    // UI Elements
    lazy var playPauseButton: SKSpriteNode = {
        let button = SKSpriteNode(imageNamed: "Pause")
        button.anchorPoint = CGPoint(x: 1, y: 1)
        button.position = CGPoint(x: Playground.Borders.right - 8, y: Playground.Borders.top - 8)
        return button
    }()
    lazy var scoreLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: Constants.appFontName)
        label.position = CGPoint(x: Playground.center.x, y: Playground.Borders.top - 24)
        label.text = ""
        label.fontColor = UIColor.whiteColor()
        label.fontSize = 20
        return label
    }()
    
    // category masks (physics, collisions, light)
    let cPlayer: UInt32 =    0x0001
    let cBullet: UInt32 =    0x0010
    let cEnemy: UInt32 =     0x0100
    
    // player
    var player = Player()
        
    var gravityField = SKFieldNode.radialGravityField()
    
    var bestScore: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(Constants.DefaultsKeys.bestScoreKey)
        }
        set {
            if newValue > bestScore {
                NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: Constants.DefaultsKeys.bestScoreKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    var score: (points: Int, nextLevelPoints: Int) = (0, GameplayConfig.levelUpScoreInterval) {
        didSet {
            if bestScore < score.points {
                bestScore = score.points
            }
            scoreLabel.text = "Score: \(score.points)"
        }
    }

    var enemiesOnline: (onlineNow: Int, limit: Int) = (0, GameplayConfig.enemiesMaxOnline) {
        didSet {
            print("enemiesOnline = \(enemiesOnline)")
        }
    }
    var bulletsMonitor: (online: Int, hitsTotal: Int, shotsTotal: Int) = (0, 0, 0)
    var gamingTime: CFTimeInterval = 0 // seconds
    
    // Sounds
    struct Sounds {
        static let coin = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
        static let kick = SKAction.playSoundFileNamed("kick.wav", waitForCompletion: false)
        static let levelUp = SKAction.playSoundFileNamed("level-up.wav", waitForCompletion: false)
        static let menuClick = SKAction.playSoundFileNamed("menu-click.wav", waitForCompletion: false)
        static let pitch = SKAction.playSoundFileNamed("pitch.wav", waitForCompletion: false)
        static let negativeHiBeep = SKAction.playSoundFileNamed("negative-beep-hi.wav", waitForCompletion: false)
        static let negativeLowBeep = SKAction.playSoundFileNamed("negative-beep-lo.wav", waitForCompletion: false)
        // TODO: find a good sound for shot
    }
    var soundsDisabled: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Constants.DefaultsKeys.soundsDisabledKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.DefaultsKeys.soundsDisabledKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: - Methods
    
    // MARK: - Lifecycle
    
    override func didMoveToView(view: SKView) {
        
        // setup game scene
        self.size = Playground.size
        self.backgroundColor = UIColor.appBackgroundColor()
        
        self.addPlayer()
        
        self.addChild(scoreLabel)
        self.score.points = 0
        
        self.addChild(playPauseButton)
        
        // setup physics, gravity
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        gravityField.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        gravityField.categoryBitMask = cEnemy
        gravityField.strength = GameplayConfig.gravityFieldstrength //measures the acceleration of the field in meters per second squared
        addChild(gravityField)
        
        // setup game timer
        let performSelector = SKAction.performSelector(#selector(GameScene.gameTimerTick), onTarget: self)
        let repeatAction = SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(1), performSelector]))
        self.runAction(repeatAction)
        
        // NSNotifications
        self.setupNotifications()
    }
    
    /**
     Called every one second
     */
    func gameTimerTick() {
        self.gamingTime += 1
        
        // place new enemies
        let newEnemiesAmount = enemiesOnline.limit - enemiesOnline.onlineNow
        self.addEnemy(newEnemiesAmount)
        
        // remove out-of-the-bounds bullets
        self.enumerateChildNodesWithName(String(Bullet)) { (node, stop) in
            if node.position.x >= Playground.size.width || node.position.x <= 0 || node.position.y >= Playground.size.height || node.position.y <= 0 {
                node.removeFromParent()
            }
        }
        
        // level up!
        if score.points > score.nextLevelPoints {
            score.nextLevelPoints += GameplayConfig.levelUpScoreInterval
            player.regenerate()
            playSound(Sounds.levelUp)
            enemiesOnline.limit += 1
            scoreLabel.fontColor = UIColor.appRedColor()
        } else {
            scoreLabel.fontColor = UIColor.whiteColor()
        }
    }
    
    func pauseGame() {
        self.paused = true
        // TODO: show popup
    }
    
    func showCountdownTimer(seconds: NSTimeInterval, message: String = "Wait", completionHandler:() -> ()) {
        // TODO: start countdown timer, next dismiss it after <time>
        completionHandler()
    }
    
    func resumeGame() {
        self.paused = false
        // TODO: dismiss popup
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Notifications
    
    func setupNotifications() {
        // Nodes notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(GameScene.bulletNodeRemovedNotification(_:)),
                                                         name:Constants.Notifications.bulletNodeRemovedNotificationKey,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(GameScene.enemyNodeRemovedNotification(_:)),
                                                         name:Constants.Notifications.enemyNodeRemovedNotificationKey,
                                                         object: nil)
        // UIApplication notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(GameScene.didEnterBackgroundNotification(_:)),
                                                         name:UIApplicationDidEnterBackgroundNotification,
                                                         object: nil)
    }
    
    func bulletNodeRemovedNotification(notification: NSNotification){
        self.bulletsMonitor.online -= 1
    }
    
    func enemyNodeRemovedNotification(notification: NSNotification){
        enemiesOnline.onlineNow -= 1
    }
    
    func didEnterBackgroundNotification(notification: NSNotification){
        self.pauseGame()
    }
    
    // MARK: - Actions
    
    func pauseButtonClicked() {
        // TODO: ignore touches on pause
        if self.paused {
            resumeGame()
            playPauseButton.texture = SKTexture(imageNamed: "Pause")
        } else {
            pauseGame()
            playPauseButton.texture = SKTexture(imageNamed: "Play")
        }
        
    }
    
    func gameOverAction() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.view?.presentScene(appDelegate.gameOverScene)
    }
    
    // MARK: - Add node, nodes generators
    
    func addPlayer() {
        player.configurePhysics(cPlayer, enemyBitmask: cEnemy, mass: 0)
        player.position = Playground.center
        player.setScale(1.0)
        player.damageForce = GameplayConfig.playerDamageForce
        player.name = String(Player)
        self.addChild(player)
    }
    
    func shotBullet(directionLocation: CGPoint) {
        let bullet = Bullet()
        bullet.setScale(1.0)
        // physics body
        bullet.configurePhysics(cBullet, enemyBitmask: cEnemy | cBullet, mass: 1)
        bullet.name = String(Bullet)
        bullet.zRotation = player.turretBody.zRotation
        bullet.position = (self.scene?.convertPoint(self.player.turretGunTube.position, fromNode: self.player.turretGunTube))!
        bullet.zPosition = -1 // behind
        bullet.damageForce = GameplayConfig.bulletDamageForce
        bullet.removeAfter(GameplayConfig.bulletTimeToLive) // time to live
        
        self.addChild(bullet)
        self.player.animateCannonShot()
        self.playSound(Sounds.menuClick)
        
        bulletsMonitor.shotsTotal += 1
        bulletsMonitor.online += 1
        
        let angleInRadians = Float(getAngleAxisRadians(directionLocation))
        bullet.applyForceToAngle(angleInRadians, scale: GameplayConfig.bulletSpeedRatio)
    }
    
    func addEnemy(amount: Int = 1) {
        var count = amount
        
        while count > 0 {
            count -= 1
            
            let enemy = Enemy(type: EnemyType.allValues.randomElement(),
                              size: CGFloat.random(GameplayConfig.enemyMinSize, GameplayConfig.enemyMaxSize))
            enemy.setScale(1)
            // physics body
            enemy.configurePhysics(cEnemy, enemyBitmask: cPlayer | cBullet | cEnemy, mass: 0)
            enemy.name = String(Enemy)
            enemy.position = generateEnemyRandomPosition()
            self.addChild(enemy)
            enemiesOnline.onlineNow += 1
            enemy.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(1, duration: 1)))
        }
    }
    
    func generateEnemyRandomPosition() -> CGPoint {
        let range: (xMax: CGFloat, yMax: CGFloat) = (Playground.size.width + GameplayConfig.enemyMaxSize,
                                                      Playground.size.height + GameplayConfig.enemyMaxSize)
        //
        let randomPositionX = CGPoint(x: CGFloat.random(0, range.xMax),
                                      y: [0, range.yMax].randomElement())
        let randomPositionY = CGPoint(x: [0, range.xMax].randomElement(),
                                      y: CGFloat.random(0, range.yMax))
        return [randomPositionX, randomPositionY].randomElement()
    }
    
    // MARK: - SKScene delegate
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if playPauseButton.containsPoint(location) || self.paused {
                pauseButtonClicked()
            } else {
                let rotateAction = SKAction.rotateToAngle(getAngleAxisRadians(location), duration: 0.05, shortestUnitArc: true)
                player.turretBody.runAction(rotateAction, completion: {
                    if self.bulletsMonitor.online < GameplayConfig.bulletsMaxOnline {
                        self.shotBullet(location)
                    } else {
                        self.playSound(Sounds.negativeHiBeep)
                    }
                })
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !self.paused {
            for touch in touches {
                let location = touch.locationInNode(self)
                let rotateAction = SKAction.rotateToAngle(getAngleAxisRadians(location), duration: 0.05, shortestUnitArc: true)
                player.turretBody.runAction(rotateAction)
                // burst mode
                self.shotBullet(location)
            }
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Player and enemy contact
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (cPlayer | cEnemy) {
            var enemy = SKPhysicsBody()
            if contact.bodyA.categoryBitMask == cPlayer {
                enemy = contact.bodyB
            } else {
                enemy = contact.bodyA
            }
            
            self.playSound(Sounds.pitch)
            
            if let enemyNode = enemy.node as? Enemy {
                self.calculateCollisionDamageForNodes(enemyNode, nodeB: self.player)
                
                self.runAction(SKAction.colorGlitch(self, originalColor: UIColor.appBackgroundColor(), duration: 0.5))
                
                // kill enemy anyway
                self.explodeNode(enemyNode, completionHandler: { (node) in
                    enemyNode.removeFromParent()
                })
                
                if self.player.healthPower == 0 {
                    // game over
                    self.paused = true
                    // TODO: show GAME OVER screen
//                    self.player.healthPower = 100
                    gameOverAction()
                }
                
                // pulsate
                self.player.runAction(SKAction.scaleTo(0.95, duration: 0.05), completion: {
                    self.player.runAction(SKAction.scaleTo(1, duration: 0.05))
                })
            }
        }
        
        // bullet and enemy contact
        if (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == (cBullet | cEnemy) {
            var bullet = SKPhysicsBody()
            var enemy = SKPhysicsBody()
            if contact.bodyA.categoryBitMask == cBullet {
                bullet = contact.bodyA
                enemy = contact.bodyB
            } else {
                bullet = contact.bodyB
                enemy = contact.bodyA
            }
            
            self.playSound(Sounds.kick)
            
            if let enemyNode = enemy.node as? Enemy {
                if let bulletNode = bullet.node as? Bullet {
                    self.calculateCollisionDamageForNodes(enemyNode, nodeB: bulletNode)
                    
                    if enemyNode.healthPower == 0 {
                        bulletsMonitor.hitsTotal += 1
                        score.points = score.points + enemyNode.damageForce
                        // TODO: regenerade player every N (5000?) points
                        self.explodeNode(enemyNode, completionHandler: { (node) in
                            enemyNode.removeFromParent()
                        })
                    }
                    
                    if bulletNode.healthPower == 0 {
                        bulletNode.removeFromParent()
                    }
                }
            }
            
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        // TODO: ricoshet
    }
    
    override func didSimulatePhysics() {
        
        self.enumerateChildNodesWithName(String(Enemy)) { (node, finished) in
            
            let maxSpeed: CGFloat = GameplayConfig.enemySpeedLimit
            
            if (node.physicsBody!.velocity.dx > maxSpeed) {
                node.physicsBody!.velocity = CGVectorMake(maxSpeed, node.physicsBody!.velocity.dy);
            } else if (node.physicsBody!.velocity.dx < -maxSpeed) {
                node.physicsBody!.velocity = CGVectorMake(-maxSpeed, node.physicsBody!.velocity.dy);
            }
            
            if (node.physicsBody!.velocity.dy > maxSpeed) {
                node.physicsBody!.velocity = CGVectorMake(node.physicsBody!.velocity.dx, maxSpeed);
            } else if (node.physicsBody!.velocity.dy < -maxSpeed) {
                node.physicsBody!.velocity = CGVectorMake(node.physicsBody!.velocity.dx, -maxSpeed);
            }
        }
    }
    
}

// MARK: - Collision, explosion

extension GameScene {
    
    /**
     Calculates damage for two provided nodes
     
     - parameter nodeA: BaseNode with damage force and power properties
     - parameter nodeB: BaseNode with damage force and power properties
     */
    func calculateCollisionDamageForNodes(nodeA: BaseNode, nodeB: BaseNode) {
        if nodeA.damageForce == 0 {
            nodeA.healthPower = 0
        } else if nodeB.damageForce == 0 {
            nodeB.healthPower = 0
        } else {
            let damageRatio = Float(nodeA.damageForce) / Float(nodeB.damageForce)
            nodeA.healthPower = nodeA.healthPower - Int(100 / damageRatio)
            nodeB.healthPower = nodeB.healthPower - Int(100 * damageRatio)
        }
    }
    
    /**
     Explosion animation, doesn't remove a node
     
     - parameter node:              node to explode, BaseNode class
     - parameter completionHandler: completion block, you cane remove exploded node here
     */
    func explodeNode(node: BaseNode, completionHandler:(node: BaseNode) -> ()) {
        let explosion = SKEmitterNode()
        explosion.particleTexture = node.texture!
        explosion.position = node.position
        explosion.zPosition = node.zPosition
        explosion.zRotation = node.zRotation
        
        node.clearBitMasks() // no interactions since explosion started
        node.texture = nil
        
        explosion.particleColor = UIColor.brownColor()
        explosion.numParticlesToEmit = Int(node.size.height)
        explosion.particleBirthRate = 150
        explosion.particleLifetime = 2
        explosion.emissionAngleRange = 360
        explosion.particleSpeed = 100
        explosion.particleSpeedRange = 50
        explosion.xAcceleration = 0
        explosion.yAcceleration = 0
        explosion.particleAlpha = 0.8
        explosion.particleAlphaRange = 0.2
        explosion.particleAlphaSpeed = -0.5
        explosion.particleScale = 0.75
        explosion.particleScaleRange = 0.4
        explosion.particleScaleSpeed = -0.5
        explosion.particleRotation = 0
        explosion.particleRotationRange = 0
        explosion.particleRotationSpeed = 0
        explosion.particleColorBlendFactor = 1
        explosion.particleColorBlendFactorRange = 0
        explosion.particleColorBlendFactorSpeed = 0
        explosion.particleBlendMode = SKBlendMode.Add
        
        self.addChild(explosion)
        
        explosion.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.removeFromParent()])) { 
            completionHandler(node: node)
        }
    }
}

// MARK: - Sound effects

extension GameScene {
    
    func vibrate() {
        if !soundsDisabled {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func playSound(soundAction: SKAction) {
        if !soundsDisabled {
            self.runAction(soundAction)
        }
    }
}

// MARK: - Helpers

extension GameScene {
    
    /**
     Converts relative touch into angle (creates direction from center)
     
     - parameter point: any point on the gamescene
     
     - returns: angle in radians that makes direction to the provided point
     */
    func getAngleAxisRadians(point: CGPoint) -> CGFloat {
        let relativeTouch = CGPoint(x: point.x - player.position.x,
                                    y: point.y - player.position.y)
        let radians = atan2(-relativeTouch.x, relativeTouch.y)
        print("relative touch:\(relativeTouch)")
        print("radains: \(radians)")
        
        return radians
    }
    
    /**
     Converts seconds to minutse and seconds
     Example: 64 seconds -> 1 min 4 sec
     
     - parameter seconds: seconds to convert
     
     - returns: mins and seconds
     */
    func secondsMinutesAndSeconds(seconds: Double) -> (minutes: Int, seconds: Int) {
        let (_,  minf) = modf(seconds / 3600)
        let (min, secf) = modf(60 * minf)
        return (Int(min), Int(60 * secf))
    }
    
}
