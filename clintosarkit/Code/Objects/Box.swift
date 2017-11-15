//
//  Box.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-13.
//  Copyright © 2017 Clinton. All rights reserved.
//

import Foundation
import ARKit

// a box that can be added to the scene
class Box: SCNNode {
    
    init(_ vector: SCNVector3, material: MaterialType) {
        super.init()
        geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        position = vector
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.mass = 2.0
        physicsBody?.contactTestBitMask = 1
        
        geometry?.materials = [Texture(material)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
