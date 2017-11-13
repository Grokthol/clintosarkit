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
    var planes: [UUID : Plane] = [:]
    var box: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeScene()
        addTapGestureRecognizer()
    }

    // initialize the configuration for the scene view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    // pause the scene view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Scene Methods

extension ViewController {
    
    func initializeScene() {
        sceneView.scene = SCNScene()
//        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
    }
    
    func addObjectToScene(object: SCNNode) {
        sceneView.scene.rootNode.addChildNode(object)
    }
}

// MARK: - ARK Delegate Methods {

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
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        if let _ = planes[planeAnchor.identifier] {
            planes.removeValue(forKey: planeAnchor.identifier)
        }
    }
}


// MARK: - Controller Methods

extension ViewController {
    
    // adds a simple tap gesture
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(withGestureRecognizer:)))
        if let _ = sceneView {
            sceneView.addGestureRecognizer(tap)
        }
    }
    
    // if the user tapped a node, destroys the node!
    // if a user taps, adds a new node
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(tapLocation, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
    
        if let hitResult = hitResults.first {
            insertGeometry(hitResult)
        }
        
        
//        let hitTest = sceneView.hitTest(tapLocation)
//        guard let node = hitTest.first?.node else {
//            let featurePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
//            if let hitTestResultWithFeaturePoints = featurePoints.first {
//                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
//
//                addObjectToScene(object: Box(vector: SCNVector3(translation.x, translation.y, translation.z)))
//            }
//            return
//        }
        
        // don't want to destroy our hard earned planes!
//        if let box = node as? Box {
//            box.removeFromParentNode()
//        }
    }
    
    func insertGeometry(_ hitResult: ARHitTestResult) {
        let insertionOffset = 0.5
        let vector = SCNVector3(hitResult.worldTransform.columns.3.x,
                                hitResult.worldTransform.columns.3.y + Float(insertionOffset),
                                hitResult.worldTransform.columns.3.z)
        let box = Box(vector: vector)
        addObjectToScene(object: box)
    }
}


