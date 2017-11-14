//
//  Sphere.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-14.
//  Copyright © 2017 Clinton. All rights reserved.
//

import Foundation
import ARKit

class Sphere: SCNNode {
    
    init(_ vector: SCNVector3) {
        super.init()
        geometry = SCNSphere(radius: 0.05)
        position = vector
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.mass = 2.0
        physicsBody?.contactTestBitMask = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
