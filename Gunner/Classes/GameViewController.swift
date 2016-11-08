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
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = self.view as! SKView
        #if DEBUG
            skView.showsFPS = true
            skView.showsNodeCount = true
        #else
            skView.showsFPS = false
            skView.showsNodeCount = false
        #endif

        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        skView.presentScene(appDelegate.menuScene)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Utility

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
