//
//  Object.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-15.
//  Copyright © 2017 Clinton. All rights reserved.
//

import ARKit

// a physical object
class PhysicalObject: SCNNode {
    
    // the type of the object
    var type: PhysicalObjectType = .box
    
    // the volume of the object, overriden by child classes
    func volume() -> Float {
        return 0.0
    }
    
    // sets the material on the physical object, including the mass and restitution
    func setMaterial(_ material: MaterialType) {
        let texture = Texture(material)
        geometry?.materials = [texture]
        physicsBody?.mass = CGFloat(volume() * texture.mass)
        physicsBody?.restitution = CGFloat(texture.restitution)
    }
}
