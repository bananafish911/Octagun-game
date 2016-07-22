//
//  GameOverScene.swift
//  Gunner
//
//  Created by Victor on 7/18/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit
import AudioToolbox
import UIKit

class GameOverScene: SKScene {
    
    // UI Elements
    lazy var playButton: SKSpriteNode = {
        return self.childNodeWithName("playButton") as! SKSpriteNode
    }()
    lazy var scoreLabel: SKLabelNode = {
        return self.childNodeWithName("scoreLabel") as! SKLabelNode
    }()
    
    struct Sounds {
        static let menuClickAction = SKAction.playSoundFileNamed("menu-click.wav", waitForCompletion: false)
        static let gameOverAction = SKAction.playSoundFileNamed("bang.wav", waitForCompletion: false)
    }
    
    var soundsDisabled: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(Constants.DefaultsKeys.soundsDisabledKey)
    }
    
    var score: Int = 0
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: - Methods
    
    // MARK: - Lifecycle
    
    override func didMoveToView(view: SKView) {
        self.size = Playground.size
        self.backgroundColor = UIColor.appBackgroundColor()
        
        self.scoreLabel.text = "Score:\n\(score)"
        
        let pulseUp = SKAction.scaleTo(1.05, duration: 0.5)
        let pulseDown = SKAction.scaleTo(0.95, duration: 0.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatActionForever(pulse)
        self.playButton.runAction(repeatPulse)
        
        self.playSound(Sounds.gameOverAction, completion: nil)
        
        self.appDelegate.presentInterstitial()
    }
    
    // MARK: - SKScene delegate
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location).name?.containsString("Button") != nil {
                self.playSound(Sounds.menuClickAction, completion: { [unowned self] in
                    if self.playButton.containsPoint(location) {
                        self.appDelegate.gameScene = GameScene()
                        self.view?.presentScene(self.appDelegate.gameScene!, transition: SKTransition.crossFadeWithDuration(0.5))
                    }
                })
            }
        }
    }
    
    // MARK: - Sounds
    
    func playSound(soundAction: SKAction, completion:(() -> ())?) {
        if self.soundsDisabled {
            completion?()
        } else {
            self.runAction(soundAction, completion: { 
                completion?()
            })
        }
    }
    
}