//
//  Texture.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-15.
//  Copyright © 2017 Clinton. All rights reserved.
//

import ARKit

// a material with additional properties for restitution and mass
class Texture: SCNMaterial {
    
    // the mass of each square foot of the material
    var mass: Float = 500
    
    // the restitution of the material
    var restitution: Float = 0.5
    
    init(_ type: MaterialType = .none) {
        super.init()
        
        // sets the mass and restitution of the texture based on the material
        switch (type) {
        case .none:
            mass = 500
            restitution = 0.5
        case .copper:
            mass = 4000
            restitution = 0.3
        case .iron:
            mass = 5000
            restitution = 0.25
        case .limestone:
            mass = 3000
            restitution = 0.2
        case .sandstone:
            mass = 2000
            restitution = 0.15
        case .plastic:
            mass = 1000
            restitution = 0.6
        case .rubber:
            mass = 1750
            restitution = 0.9
        }
        
        // if there is no texture set, nil everything
        if type == .none {
            diffuse.contents = nil
            roughness.contents = nil
            metalness.contents = nil
            normal.contents = nil
            return
        }
        
        // sets the contents of the material
        
        diffuse.contents = UIImage(named: "\(type.rawValue)-albedo.png")
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
        
        roughness.contents = UIImage(named: "\(type.rawValue)-roughness.png")
        roughness.wrapS = .repeat
        roughness.wrapT = .repeat
        
        metalness.contents = UIImage(named: "\(type.rawValue)-metal.png")
        metalness.wrapS = .repeat
        metalness.wrapT = .repeat
        
        normal.contents = UIImage(named: "\(type.rawValue)-normal.png")
        normal.wrapS = .repeat
        normal.wrapT = .repeat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
