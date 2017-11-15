//
//  Texture.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-15.
//  Copyright © 2017 Clinton. All rights reserved.
//

import ARKit

class Texture: SCNMaterial {
    
    init(_ type: MaterialType = .none) {
        super.init()
        
        if type == .none {
            return
        }
        
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
