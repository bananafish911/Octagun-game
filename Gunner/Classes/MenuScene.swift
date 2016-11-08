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
        return self.childNode(withName: "playButton") as! SKSpriteNode
    }()
    lazy var rateButton: SKSpriteNode = {
        return self.childNode(withName: "rateButton") as! SKSpriteNode
    }()
    lazy var soundButton: SKSpriteNode = {
        return self.childNode(withName: "soundButton") as! SKSpriteNode
    }()
    lazy var chatButton: SKSpriteNode = {
        return self.childNode(withName: "chatButton") as! SKSpriteNode
    }()
    
    lazy var scoreLabel: SKLabelNode = {
        return self.childNode(withName: "scoreLabel") as! SKLabelNode
    }()
    
    let menuClickSoundAction = SKAction.playSoundFileNamed("menu-click.wav", waitForCompletion: false)
    
    var soundsDisabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.DefaultsKeys.soundsDisabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.DefaultsKeys.soundsDisabledKey)
            UserDefaults.standard.synchronize()
        }
    }

    var bestScore: Int {
        return UserDefaults.standard.integer(forKey: Constants.DefaultsKeys.bestScoreKey)
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Methods
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        self.size = Playground.size
        self.backgroundColor = UIColor.appBackgroundColor()
        
        scoreLabel.text = "Best score:\n\(bestScore)"
        updateSoundButton()
        updatePlayButton()
        
        let pulseUp = SKAction.scale(to: 1.05, duration: 0.5)
        let pulseDown = SKAction.scale(to: 0.95, duration: 0.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        self.playButton.run(repeatPulse)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if self.atPoint(location).name?.contains("Button") != nil {
                let optionalSound = soundsDisabled ? SKAction.wait(forDuration: 0) : menuClickSoundAction
                self.run(optionalSound, completion: { [unowned self] in
                    // buttons
                    
                    if self.playButton.contains(location) {
                        if self.appDelegate.gameScene == nil {
                            self.appDelegate.gameScene = GameScene()
                        }
                        self.view?.presentScene(self.appDelegate.gameScene!, transition: SKTransition.crossFade(withDuration: 0.5))
                        
                    } else if self.rateButton.contains(location) {
                        // TODO: appstore uiwebview
                        let iTunesUrl = URL(string: Constants.iTunesUrlString)
                        if iTunesUrl != nil && UIApplication.shared.canOpenURL(iTunesUrl!) {
                            UIApplication.shared.openURL(iTunesUrl!)
                        }
                        FIRAnalytics.logEvent(withName: "userAction", parameters: ["button": "rate" as NSObject])
                        
                    } else if self.soundButton.contains(location) {
                        self.soundsDisabled = !self.soundsDisabled
                        self.updateSoundButton()
                        
                    } else if self.chatButton.contains(location) {
                        Smooch.show()
                        FIRAnalytics.logEvent(withName: "userAction", parameters: ["button": "chat" as NSObject])
                    }
                })
            }
        }
    }
    
}
