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
    let gameOverSoundAction = SKAction.playSoundFileNamed("bang.wav", waitForCompletion: false) // bang.wav gameover.wav
    
    var score: Int = 0
    
    // MARK: - Methods
    
    // MARK: - Lifecycle
    
    override func didMoveToView(view: SKView) {
        self.size = Playground.size
        self.backgroundColor = UIColor.appBackgroundColor()
        
        self.runAction(gameOverSoundAction)
        
        self.scoreLabel.text = "Score:\n\(score)"
    }
    
    // MARK: - Actions
    
    func playButtonClick() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // reload game
        appDelegate.gameScene = GameScene()
        self.view?.presentScene(appDelegate.gameScene)
    }
    
    // MARK: - SKScene delegate
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location).name?.containsString("Button") != nil {
                self.runAction(menuClickSoundAction, completion: { [unowned self] in
                    // buttons
                    if self.playButton.containsPoint(location) {
                        self.playButtonClick()
                    }
                    })
            }
        }
    }
    
}