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
        let texture = SKTexture(imageNamed: type.rawValue)
        texture.filteringMode = .nearest
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: size, height: size))
    }
    
    override func removeFromParent() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.enemyNodeRemovedNotificationKey),
                                                                      object: nil,
                                                                      userInfo: nil)
        }
        super.removeFromParent()
    }
}
