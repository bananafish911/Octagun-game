//
//  GameViewController.swift
//  Gunner
//
//  Created by Victor on 7/9/16.
//  Copyright (c) 2016 Bananaapps. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var menuScene: MenuScene?
    var gameScene: GameScene?
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = MenuScene(fileNamed:"MenuScene") {
            self.menuScene = scene
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//            return .Portrait
//        } else {
//            return .All
//        }
    }
    
    // MARK: - Utility

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
