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
import FirebaseAnalytics

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
    lazy var chatButton: SKSpriteNode = {
        return self.childNodeWithName("chatButton") as! SKSpriteNode
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
        return NSUserDefaults.standardUserDefaults().integerForKey(Constants.DefaultsKeys.bestScoreKey)
    }
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: - Methods
    
    // MARK: - Lifecycle
    
    override func didMoveToView(view: SKView) {
        self.size = Playground.size
        self.backgroundColor = UIColor.appBackgroundColor()
        
        scoreLabel.text = "Best score:\n\(bestScore)"
        updateSoundButton()
        updatePlayButton()
        
        let pulseUp = SKAction.scaleTo(1.05, duration: 0.5)
        let pulseDown = SKAction.scaleTo(0.95, duration: 0.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatActionForever(pulse)
        self.playButton.runAction(repeatPulse)
    }
    
    func updateSoundButton() {
        if soundsDisabled {
            soundButton.texture = SKTexture(imageNamed: "SoundOffButton")
        } else {
            soundButton.texture = SKTexture(imageNamed: "SoundOnButton")
        }
    }
    
    func updatePlayButton() {
        if appDelegate.gameScene == nil {
            playButton.texture = SKTexture(imageNamed: "Play-button")
        } else {
            playButton.texture = SKTexture(imageNamed: "Continue-button")
        }
    }
    
    // MARK: - SKScene delegate
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location).name?.containsString("Button") != nil {
                let optionalSound = soundsDisabled ? SKAction.waitForDuration(0) : menuClickSoundAction
                self.runAction(optionalSound, completion: { [unowned self] in
                    // buttons
                    
                    if self.playButton.containsPoint(location) {
                        if self.appDelegate.gameScene == nil {
                            self.appDelegate.gameScene = GameScene()
                        }
                        self.view?.presentScene(self.appDelegate.gameScene!, transition: SKTransition.crossFadeWithDuration(0.5))
                        
                    } else if self.rateButton.containsPoint(location) {
                        // TODO: appstore uiwebview
                        let iTunesUrl = NSURL(string: Constants.iTunesUrlString)
                        if iTunesUrl != nil && UIApplication.sharedApplication().canOpenURL(iTunesUrl!) {
                            UIApplication.sharedApplication().openURL(iTunesUrl!)
                        }
                        FIRAnalytics.logEventWithName("userAction", parameters: ["button": "rate"])
                        
                    } else if self.soundButton.containsPoint(location) {
                        self.soundsDisabled = !self.soundsDisabled
                        self.updateSoundButton()
                        
                    } else if self.chatButton.containsPoint(location) {
                        Smooch.show()
                        FIRAnalytics.logEventWithName("userAction", parameters: ["button": "chat"])
                    }
                })
            }
        }
    }
    
}