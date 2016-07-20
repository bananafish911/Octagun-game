//
//  MenuScene.swift
//  Gunner
//
//  Created by Victor on 7/18/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit
import AudioToolbox
import UIKit

class MenuScene: SKScene {
    
    // UI Elements
    lazy var playButton: SKSpriteNode = {
        return self.childNodeWithName("playButton") as! SKSpriteNode
    }()
    lazy var rateButton: SKSpriteNode = {
        return self.childNodeWithName("rateButton") as! SKSpriteNode
    }()
    lazy var soundButton: SKSpriteNode = {
        return self.childNodeWithName("soundButton") as! SKSpriteNode
    }()
    lazy var scoreLabel: SKLabelNode = {
        return self.childNodeWithName("scoreLabel") as! SKLabelNode
    }()
    
    let menuClickSoundAction = SKAction.playSoundFileNamed("menu-click.wav", waitForCompletion: false)
    
    var soundsDisabled: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Constants.DefaultsKeys.soundsDisabledKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.DefaultsKeys.soundsDisabledKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

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
        self.view?.presentScene(appDelegate.gameScene)
    }
    
    func soundButtonClick() {
        //
    }
    
    func rateButtonClick() {
        //
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
                    } else if self.soundButton.containsPoint(location) {
                        self.soundButtonClick()
                    } else if self.rateButton.containsPoint(location) {
                        self.rateButtonClick()
                    }
                })
            }
        }
    }
    
    // MARK: - Utility
    
    func updateScoreLabel() {
        scoreLabel.text = "Best score:\n\(bestScore)"
    }
    
}