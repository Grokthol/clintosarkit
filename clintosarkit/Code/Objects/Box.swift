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
class Box: PhysicalObject {
    
    var width: Float = 0.1
    var height: Float = 0.1
    var length: Float = 0.1
    
    init(_ vector: SCNVector3, material: MaterialType) {
        super.init()
        geometry = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(length), chamferRadius: 0)
        position = vector
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.contactTestBitMask = 1
        
        type = .box
        setMaterial(material)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func volume() -> Float {
        return width * height * length
    }
}
