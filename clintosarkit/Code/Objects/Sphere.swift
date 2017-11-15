//
//  Sphere.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-14.
//  Copyright © 2017 Clinton. All rights reserved.
//

import Foundation
import ARKit

// a sphere that can be added to the scene
class Sphere: PhysicalObject {
    
    var radius: Float = 0.1
    
    init(_ vector: SCNVector3, material: MaterialType, scale: Float) {
        super.init()
        geometry = SCNSphere(radius: CGFloat(radius * scale))
        position = vector
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry!, options: [:]))
        physicsBody?.contactTestBitMask = 1
        
        type = .sphere
        setMaterial(material)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func volume() -> Float {
        return (4/3 * .pi * radius * radius * radius)
    }
}
