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
    
    var width: Float = 0.2
    var height: Float = 0.2
    var length: Float = 0.2
    
    init(_ vector: SCNVector3, material: MaterialType, scale: Float) {
        super.init()
        geometry = SCNBox(width: CGFloat(width * scale), height: CGFloat(height * scale), length: CGFloat(length * scale), chamferRadius: 0)
        position = vector
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry!, options: [:]))
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
