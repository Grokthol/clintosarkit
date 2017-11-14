//
//  ViewController.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-13.
//  Copyright © 2017 Clinton. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    var light: SCNLight = SCNLight()
    var planes: [UUID : Plane] = [:]
    var boxes: Set<SCNNode> = Set<SCNNode>()
    var bottomPlane: SCNNode!
    var settings: Settings!
    var sessionConfiguration: ARWorldTrackingConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeScene()
        addTapGestureRecognizer()
        addLongPressGestureRecognizer()
    }

    // initialize the configuration for the scene view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if settings.displayWorldOrigin && settings.displayFeaturePoints {
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        } else if settings.displayWorldOrigin {
            sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        } else if settings.displayFeaturePoints {
            sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        }
        sceneView.showsStatistics = settings.displayStatistics
        
        sceneView.session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // pause the scene view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}


// MARK: - Scene Methods

extension ViewController {
    
    // fires up the scene
    func initializeScene() {
        settings = Settings()
        
        sessionConfiguration = ARWorldTrackingConfiguration()
        sessionConfiguration.isLightEstimationEnabled = true
        sessionConfiguration.planeDetection = .horizontal
        
        sceneView.scene = SCNScene()
        sceneView.delegate = self
        addBottomPlane()
        addLights()
    }
    
    // generate the bottom bounds of the world, used for destroying objects that have fallen off
    func addBottomPlane() {
        let bottomBox = SCNBox(width: 1000, height: 0.5, length: 1000, chamferRadius: 0)
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor.clear
        bottomBox.materials = [bottomMaterial]
        bottomPlane = SCNNode(geometry: bottomBox)
        bottomPlane.position = SCNVector3(0,-10,0)
        bottomPlane.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        bottomPlane.physicsBody?.contactTestBitMask = 1
        addObject(bottomPlane)
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    // adds an ambient light to the scene
    func addLights() {
        sceneView.autoenablesDefaultLighting = false
        light.type = .omni
    
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0,0,0)
        addObject(lightNode)
    }
    
    // adds an object to the scene
    func addObject(_ object: SCNNode) {
        sceneView.scene.rootNode.addChildNode(object)
    }
    
    // adds a box that drops onto the plane
    func insertGeometry(_ hitResult: ARHitTestResult) {
        let insertionOffset = 0.5
        let vector = SCNVector3(hitResult.worldTransform.columns.3.x,
                                hitResult.worldTransform.columns.3.y + Float(insertionOffset),
                                hitResult.worldTransform.columns.3.z)
        let box = Box(vector: vector)
        boxes.insert(box)
        addObject(box)
    }
    
    func explode(_ hitResult: ARHitTestResult) {
        // the max distance that the explosion will effect
        let explosionDistance: Float = 2
        
        // the point of the explostion
        let explosionOffset: Float = 0.5
        let explosionPoint = SCNVector3(hitResult.worldTransform.columns.3.x,
                                         hitResult.worldTransform.columns.3.y + explosionOffset,
                                         hitResult.worldTransform.columns.3.z)
        
        for box in boxes {
            // the distance vector between the box and the explosion
            var distanceVector = SCNVector3(box.worldPosition.x - explosionPoint.x,
                                      box.worldPosition.y - explosionPoint.y,
                                      box.worldPosition.z - explosionPoint.z)
            
            // the length between the origin of the explosion and the box
            let distance = sqrt(distanceVector.x * distanceVector.x
                + distanceVector.y * distanceVector.y
                + distanceVector.z * distanceVector.z)
        
            // the explosive power for the box
            let explosionPower = max(0, (explosionDistance - distance))
//            explosionPower = explosionPower * explosionPower * 2
            
            // scale the explosion power in each direction
            distanceVector.x = (distanceVector.x / distance) * explosionPower;
            distanceVector.y = (distanceVector.y / distance) * explosionPower;
            distanceVector.z = (distanceVector.z / distance) * explosionPower;
            
            // applies the explosion to the box
            box.physicsBody?.applyForce(distanceVector, asImpulse: true)
        }
    }
}


// MARK: - Gesture Recognizer Methods

extension ViewController {
    
    // adds a simple tap gesture
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(withGestureRecognizer:)))
        if let _ = sceneView {
            sceneView.addGestureRecognizer(tap)
        }
    }
    
    // if a user taps on a plane, drops a new box onto it!
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if let hitResult = hitResults.first {
            insertGeometry(hitResult)
        }
    }
    
    // adds a long press gesture
    func addLongPressGestureRecognizer() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didPress(withGestureRecognizer:)))
        if let _ = sceneView {
            sceneView.addGestureRecognizer(press)
        }
    }
    
    // causes an explosion
    @objc func didPress(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        if recognizer.state == .began {
            return
        }
        
        let pressLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(pressLocation, types: .existingPlaneUsingExtent)
        if let hitResult = hitResults.first {
            explode(hitResult)
        }
    }
}

// MARK: - Scene View Delegate Methods
    
    extension ViewController : ARSCNViewDelegate {
        
        // this is called every time ARK kit detects a new plane
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                let plane = Plane(anchor: planeAnchor)
                node.addChildNode(plane)
                planes[planeAnchor.identifier] = plane
            }
        }
        
        // update existing planes
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
            
            if let plane = planes[planeAnchor.identifier] {
                plane.update(anchor: planeAnchor)
            }
        }
        
        // removes planes that no longer exist
        func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else {
                return
            }
            
            if let _ = planes[planeAnchor.identifier] {
                planes.removeValue(forKey: planeAnchor.identifier)
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            if let light = sceneView.session.currentFrame?.lightEstimate {
                self.light.intensity = light.ambientIntensity
            }
        }
//        - (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
//        ARLightEstimate *estimate = self.sceneView.session.currentFrame.lightEstimate;
//        if (!estimate) {
//        return;
//        }
//        // TODO: Put this on the screen
//        NSLog(@"light estimate: %f", estimate.ambientIntensity);
//        // Here you can now change the .intensity property of your lights
//        // so they respond to the real world environment
//        }
    }
    
// MARK: - Contact Delegate Methods

extension ViewController: SCNPhysicsContactDelegate {
    
    // physics contact handler
    // essentially only used if a cube hits the bottom bounds of the world
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.isEqual(bottomPlane) || contact.nodeB.isEqual(bottomPlane) {
            if contact.nodeA.isEqual(bottomPlane) {
                boxes.remove(contact.nodeB)
                contact.nodeB.removeFromParentNode()
            } else if contact.nodeB.isEqual(bottomPlane) {
                boxes.remove(contact.nodeA)
                contact.nodeA.removeFromParentNode()
            }
        }
    }
}

// MARK: - Button Delegate Methods

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "optionsSegue" {
            if let nav = segue.destination as? UINavigationController, let vc = nav.topViewController as? OptionsViewController {
                vc.settings = settings
                vc.delegate = self
            }
        }
    }
    
    @IBAction func didSelectOptionsButton(_ sender: Any) {
        performSegue(withIdentifier: "optionsSegue", sender: self)
    }
}

// MARK: - Options Delegate Methods

extension ViewController: OptionsDelegate {
    
    // modified delegate settings. updates the debug settings
    func modifiedSettings(_ settings: Settings?) {
        if let settings = settings {
            self.settings = settings
        }
    }
}

