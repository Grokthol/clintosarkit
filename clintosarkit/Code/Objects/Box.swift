//
//  Box.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-13.
//  Copyright © 2017 Clinton. All rights reserved.
//

import Foundation
import ARKit

class Box: SCNNode {
    
    init(_ vector: SCNVector3) {
        super.init()
        geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        position = vector
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.mass = 2.0
        physicsBody?.contactTestBitMask = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
