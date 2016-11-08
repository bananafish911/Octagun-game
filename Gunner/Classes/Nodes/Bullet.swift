//
//  Bullet.swift
//  Gunner
//
//  Created by Victor on 7/10/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import SpriteKit

class Bullet: BaseNode {
    
    // MARK: - Properties
    
    // MARK: - Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        let texture = SKTexture(imageNamed: "Bullet")
        texture.filteringMode = .nearest
        super.init(texture: texture, color: UIColor.appBlueColor(), size: texture.size())
    }
    
    override func removeFromParent() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.bulletNodeRemovedNotificationKey),
                                                                      object: nil,
                                                                      userInfo: nil)
        }
        super.removeFromParent()
    }
    
    func removeAfter(_ timeToLiveSeconds: TimeInterval) {
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: timeToLiveSeconds),
            SKAction.removeFromParent()
            ]))
    }
    
    func applyForceToAngle(_ radians: Float, scale: CGFloat) {
        let dx = CGFloat(cosf(radians + Float(M_PI_2)))
        let dy = CGFloat(sinf(radians + Float(M_PI_2)))
        let vector = CGVector(dx: dx * scale, dy: dy * scale)
        self.physicsBody?.applyForce(vector)
    }
}
