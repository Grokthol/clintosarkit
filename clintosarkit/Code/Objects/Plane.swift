//
//  Plane.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-13.
//  Copyright © 2017 Clinton. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        self.anchor = anchor
        
        // create the plane geometry
        let planeHeight: CGFloat = 0.001
        planeGeometry = SCNBox(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z), length: planeHeight, chamferRadius: 0)
        
        let planeNode = SCNNode(geometry: planeGeometry)
        
        // center it
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        // rotate it
        planeNode.transform = SCNMatrix4MakeRotation(-.pi / 2.0, 1.0, 0.0, 0.0)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: [:]))
        
        // set the material the a grid
        let material = SCNMaterial()
        let img = UIImage(named: "grid")
        material.diffuse.contents = img
        planeGeometry.materials = [material]
    
        setTextureScale()
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension Plane {
    
    // updates the note to have the new position
    func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        if let childNode = childNodes.first {
            childNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
            childNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: [:]))
        }
        
        setTextureScale()
    }
    
    // textures the plane for its new size
    func setTextureScale() {
        
        if let material = planeGeometry.materials.first {
            material.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(planeGeometry.width),
                                                                     Float(planeGeometry.height), 1)
            material.diffuse.wrapS = .repeat
            material.diffuse.wrapT = .repeat
        }
    }
}
