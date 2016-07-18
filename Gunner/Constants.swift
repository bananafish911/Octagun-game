//
//  Constants.swift
//  Gunner
//
//  Created by Victor on 7/11/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import Foundation
import UIKit

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