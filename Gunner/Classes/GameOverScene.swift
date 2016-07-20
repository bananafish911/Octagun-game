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
    
    let menuClickSoundAction = SKAction.playSoundFileNamed("menu-click.wav", waitForCompletion: false)
    
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
    
    // MARK: - Methods
    
    // MARK: - Lifecycle
    
    override func didMoveToView(view: SKView) {
        self.size = Playground.size
        self.backgroundColor = UIColor.appBackgroundColor()
    }
    
    // MARK: - Actions
    
    func playButtonClick() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.gameScene = nil
        appDelegate.gameScene = GameScene(fileNamed:"GameScene")
        self.view?.presentScene(appDelegate.gameScene)
    }
    
    // MARK: - SKScene delegate
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location).name?.containsString("Button") != nil {
                self.runAction(menuClickSoundAction)
            }
            
            // buttons
            if playButton.containsPoint(location) {
                playButtonClick()
            }
        }
    }
    
    // MARK: - Utility
    
    func updateScoreLabel() {
        scoreLabel.text = "Best score:\n\(bestScore)"
    }
    
}