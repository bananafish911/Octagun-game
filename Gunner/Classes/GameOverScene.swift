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
import FirebaseAnalytics

class GameOverScene: SKScene {
    
    // UI Elements
    lazy var playButton: SKSpriteNode = {
        return self.childNode(withName: "playButton") as! SKSpriteNode
    }()
    lazy var scoreLabel: SKLabelNode = {
        return self.childNode(withName: "scoreLabel") as! SKLabelNode
    }()
    
    struct Sounds {
        static let menuClickAction = SKAction.playSoundFileNamed("menu-click.wav", waitForCompletion: false)
        static let gameOverAction = SKAction.playSoundFileNamed("bang.wav", waitForCompletion: false)
    }
    
    var soundsDisabled: Bool {
        return UserDefaults.standard.bool(forKey: Constants.DefaultsKeys.soundsDisabledKey)
    }
    
    var score: Int = 0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Methods
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        self.size = Playground.size
        self.backgroundColor = UIColor.appBackgroundColor()
        
        self.scoreLabel.text = "Score:\n\(score)"
        
        let pulseUp = SKAction.scale(to: 1.05, duration: 0.5)
        let pulseDown = SKAction.scale(to: 0.95, duration: 0.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        self.playButton.run(repeatPulse)
        
        self.playSound(Sounds.gameOverAction, completion: nil)
        
        self.appDelegate.presentInterstitial()
    }
    
    // MARK: - SKScene delegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if self.atPoint(location).name?.contains("Button") != nil {
                self.playSound(Sounds.menuClickAction, completion: { [unowned self] in
                    if self.playButton.contains(location) {
                        FIRAnalytics.logEvent(withName: "playAgain", parameters: ["prevScore": "\(self.score)" as NSObject,
                                                                                "prevTime": "\(self.appDelegate.gameScene?.gamingTime)" as NSObject])
                        self.appDelegate.gameScene = GameScene()
                        self.view?.presentScene(self.appDelegate.gameScene!, transition: SKTransition.crossFade(withDuration: 0.5))
                    }
                })
            }
        }
    }
    
    // MARK: - Sounds
    
    func playSound(_ soundAction: SKAction, completion:(() -> ())?) {
        if self.soundsDisabled {
            completion?()
        } else {
            self.run(soundAction, completion: { 
                completion?()
            })
        }
    }
    
}
