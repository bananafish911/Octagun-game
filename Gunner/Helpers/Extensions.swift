//
//  Extensions.swift
//  Gunner
//
//  Created by Victor on 7/10/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import SpriteKit

extension Int {
    /// SwiftRandom extension
    static func random(lower: Int = 0, _ upper: Int = 100) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    var array: [Int] {
        return description.characters.map{Int(String($0)) ?? 0}
    }
}

extension Double {
    /// SwiftRandom extension
    static func random(lower: Double = 0, _ upper: Double = 100) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

extension Float {
    /// SwiftRandom extension
    static func random(lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

extension CGFloat {
    /// SwiftRandom extension
    static func random(lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}

extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}

extension Array {
    func randomElement() -> Element {
        let len = UInt32(self.count)
        let random = Int(arc4random_uniform(len))
        return self[random]
    }
}

extension SKAction {
    /**
     * Causes the scene background to flash for duration seconds.
     */
    static func colorGlitch(scene: SKScene, originalColor: UIColor, duration: NSTimeInterval) -> SKAction {
        return SKAction.customActionWithDuration(duration) {(node, elapsedTime) in
            if elapsedTime < CGFloat(duration) {
                scene.backgroundColor = SKColorWithRGB(Int.random(0...255), g: Int.random(0...255), b: Int.random(0...255))
            } else {
                scene.backgroundColor = originalColor
            }
        }
    }
}