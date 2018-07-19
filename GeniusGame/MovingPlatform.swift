//
//  MovingPlatform.swift
//  GeniusGame
//
//  Created by campstud on 7/19/18.
//  Copyright © 2018 campstud. All rights reserved.
//

import SpriteKit

class MovingPlatform: SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
