//
//  Constants.swift
//  Gunner
//
//  Created by Victor on 7/11/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import Foundation
import UIKit

/**
 *  App constants
 */
struct Constants {
    
    /*******************************
     *                              *
     *      App Personalization     *
     *                              *
     *******************************/
    
    static let appFontName = "Silom"
    
    struct Notifications {
        static let bulletNodeRemovedNotificationKey =   "bulletNodeRemovedNotificationKey"
        static let enemyNodeRemovedNotificationKey =    "enemyNodeRemovedNotificationKey"
    }
    
    struct DefaultsKeys {
        static let soundsDisabledKey =                  "soundsDisabledKey"
        static let bestScoreKey =                       "bestScoreKey"
    }
}

/**
 *  Gameplay configuration here
 */
struct GameplayConfig {
    // TODO: dont forget bout balance
    static let gravityFieldstrength: Float = 0.5 //measures the acceleration of the field in meters per second squared
    static let playerDamageForce: Int = 320
    static let levelUpScoreInterval: Int = 1000
    // Bullet
    static let bulletDamageForce: Int = 48 // Example: one bullet with 32 DF kills enemy with size 32
    static let bulletSpeedRatio: CGFloat = 10000 // starting speed ratio
    static let bulletsMaxOnline: Int = 8 // shots limit
    static let bulletTimeToLive: NSTimeInterval = 4 // in seconts
    // Enemy
    static let enemyMinSize: CGFloat = 32 // minimum size of the enemy, also affects to the damageForce (size == damageF)
    static let enemyMaxSize: CGFloat = 64 // maximum size of the enemy, also affects to the damageForce (size == damageF)
    static let enemySpeedLimit: CGFloat = 20 // m per second^2
    static let enemiesMaxOnline: Int = 8 // limit enemies on scene
}

/**
 *  Playground == screen size
 */
struct Playground {
    static let size = UIScreen.mainScreen().bounds.size
    static let center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
    
    struct Borders {
        static let top = UIScreen.mainScreen().bounds.size.height
        static let bottom = 0
        static let left = 0
        static let right = UIScreen.mainScreen().bounds.size.width
    }
}

extension UIColor {
    
    class func appBackgroundColor() -> UIColor {
        return UIColor.appGreenColor()
    }
    
    class func appDarkElementsColor() -> UIColor {
        return UIColor(hex: 0x4A4A4A)
    }
    
    class func appLightElementsColor() -> UIColor {
        return UIColor(hex: 0xFFFFFF)
    }
    
    class func appGreenColor() -> UIColor {
        return UIColor(hex: 0x5CAB3F)
    }
    
    class func appBlueColor() -> UIColor {
        return UIColor(hex: 0x0075FF)
    }
    
    class func appRedColor() -> UIColor {
        return UIColor(hex: 0xD0021B)
    }
    
    class func appYellowColor() -> UIColor {
        return UIColor(hex: 0xF8E71C)
    }
    
    class func appOrangeColor() -> UIColor {
        return UIColor(hex: 0xF5A623)
    }
    
    class func appMagentaColor() -> UIColor {
        return UIColor(hex: 0xBD10E0)
    }
    
}

extension UIFont {
    
    class func appFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: Constants.appFontName, size: size)!
    }
    
}