//
//  Enemy.swift
//  Gunner
//
//  Created by Victor on 7/10/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit

enum EnemyType: String {
    case Circle = "Circle"
    case Polygon = "Polygon"
    case Rect = "Rect"
    case Triangle = "Triangle"
    
    static let allValues = [Circle, Polygon, Rect, Triangle]
}

class Enemy: BaseNode {
    
    // MARK: - Properties
    
    // MARK: - Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(type: EnemyType, size: CGFloat = 32) {
        // TODO: recpect aspect rate !!
        let texture = SKTexture(imageNamed: type.rawValue)
        texture.filteringMode = .Nearest
        super.init(texture: texture, color: UIColor.clearColor(), size: CGSize(width: size, height: size))
    }
    
    override func removeFromParent() {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.enemyNodeRemovedNotificationKey,
                                                                      object: nil,
                                                                      userInfo: nil)
        }
        super.removeFromParent()
    }
}