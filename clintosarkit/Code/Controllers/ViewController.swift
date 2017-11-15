//
//  ViewController.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-13.
//  Copyright © 2017 Clinton. All rights reserved.
//

import UIKit
import ARKit

// main view controller
class ViewController: UIViewController {
    
    // misc variables
    @IBOutlet weak var sceneView: ARSCNView!
    var lightNode: SCNNode = SCNNode()
    var planes: [UUID : Plane] = [:]
    var objects: Set<SCNNode> = Set<SCNNode>()
    var bottomPlane: SCNNode!
    var settings: Settings = Settings()
    var sessionConfiguration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    
    // material selection variables
    let materialOptions = [MaterialType.none, MaterialType.copper, MaterialType.iron,
                           MaterialType.limestone, MaterialType.sandstone, MaterialType.rubber,
                           MaterialType.plastic]
    var selectedObjectMaterial: MaterialType = .none
    var selectedPlaneMaterial: MaterialType = .none
    var pickerMode: PickerMode = .object
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeScene()
    }
    
    // initialize the configuration for the scene view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // uses the settings object to update the scene settings
        if settings.displayWorldOrigin && settings.displayFeaturePoints {
            sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        } else if settings.displayWorldOrigin {
            sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        } else if settings.displayFeaturePoints {
            sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        }
        sceneView.showsStatistics = settings.displayStatistics
        sceneView.autoenablesDefaultLighting = settings.enableDefaultLighting
        if settings.enableDefaultLighting, let _ = lightNode.light {
            removeObject(lightNode)
        }
        
        sceneView.session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // pause the scene view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}


// MARK: - Scene Methods

private extension ViewController {
    
    // fires up the scene
    func initializeScene() {
        sessionConfiguration.isLightEstimationEnabled = true
        sessionConfiguration.planeDetection = .horizontal
        sceneView.scene = SCNScene()
        sceneView.delegate = self
        addGestureRecognizers()
        addBottomPlane()
        addLights()
    }
    
    // adds an object to the scene
    func addObject(_ object: SCNNode) {
        sceneView.scene.rootNode.addChildNode(object)
    }
    
    // removes an object from the scene
    func removeObject(_ object: SCNNode) {
        object.removeFromParentNode()
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
        let light = SCNLight()
        light.type = .omni
        lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0,0,0)
        addObject(lightNode)
    }
    
    // adds gesture recognizers to the view to perform some fun actions
    func addGestureRecognizers() {
        addTapGestureRecognizer()
        addTwoFingerTapGestureRecognizer()
        addLongPressGestureRecognizer()
        addTwoFingerLongPressGestureRecognizer()
    }
    
    // adds a box that drops onto the plane
    func insert(_ hitResult: ARHitTestResult, type: PhysicalObjectType) {
        let insertionOffset = 0.5
        let vector = SCNVector3(hitResult.worldTransform.columns.3.x,
                                hitResult.worldTransform.columns.3.y + Float(insertionOffset),
                                hitResult.worldTransform.columns.3.z)
        
        var object: SCNNode!
        if type == .box {
            object = Box(vector, material: selectedObjectMaterial)
        } else if type == .sphere {
            object = Sphere(vector, material: selectedObjectMaterial)
        }
        objects.insert(object)
        addObject(object)
    }
    
    // applies a force to a box relative to the distance from the epicenter
    func force(_ hitResult: ARHitTestResult, type: ForceType) {
        // the max distance that the force will effect
        let forceDistance: Float = 2
        
        // the point of the force
        let forceOffset: Float = 0.5
        let forcePoint = SCNVector3(hitResult.worldTransform.columns.3.x,
                                    hitResult.worldTransform.columns.3.y + forceOffset,
                                    hitResult.worldTransform.columns.3.z)
        
        for object in objects {
            // the distance vector between the box and the force
            var distanceVector = SCNVector3()
            if type == .explode {
                distanceVector = SCNVector3(object.worldPosition.x - forcePoint.x,
                                            object.worldPosition.y - forcePoint.y,
                                            object.worldPosition.z - forcePoint.z)
            } else if type == .vacuum {
                distanceVector = SCNVector3(forcePoint.x - object.worldPosition.x,
                                            forcePoint.y - object.worldPosition.y,
                                            forcePoint.z - object.worldPosition.z)
            }
            
            // the length between the origin of the force and the object
            let distance = sqrt(distanceVector.x * distanceVector.x
                + distanceVector.y * distanceVector.y
                + distanceVector.z * distanceVector.z)
            
            // the force on the object
            let force = max(0, (forceDistance - distance))
            
            // scale the force in each direction
            distanceVector.x = (distanceVector.x / distance) * force;
            distanceVector.y = (distanceVector.y / distance) * force;
            distanceVector.z = (distanceVector.z / distance) * force;
            
            // applies the force to the object
            object.physicsBody?.applyForce(distanceVector, asImpulse: true)
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
            insert(hitResult, type: .box)
        }
    }
    
    // add a two finger tap gesture
    func addTwoFingerTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTwoFingerTap(withGestureRecognizer:)))
        tap.numberOfTouchesRequired = 2
        if let _ = sceneView {
            sceneView.addGestureRecognizer(tap)
        }
    }
    
    // if a user taps on a plane with two fingers, drops a new sphere onto it!
    @objc func didTwoFingerTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if let hitResult = hitResults.first {
            insert(hitResult, type: .sphere)
        }
    }
    
    // adds a long press gesture
    func addLongPressGestureRecognizer() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didPress(withGestureRecognizer:)))
        if let _ = sceneView {
            sceneView.addGestureRecognizer(press)
        }
    }
    
    // if a user presses on a location, forces objects away
    @objc func didPress(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        if recognizer.state == .began {
            return
        }
        
        let pressLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(pressLocation, types: .existingPlaneUsingExtent)
        if let hitResult = hitResults.first {
            force(hitResult, type: .explode)
        }
    }
    
    // adds a two finger long press gesture
    func addTwoFingerLongPressGestureRecognizer() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didTwoFingerPress(withGestureRecognizer:)))
        press.numberOfTouchesRequired = 2
        if let _ = sceneView {
            sceneView.addGestureRecognizer(press)
        }
    }
    
    // if a user presses on a location with two fingers, forces objects towards the location
    @objc func didTwoFingerPress(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        if recognizer.state == .began {
            return
        }
        
        let pressLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(pressLocation, types: .existingPlaneUsingExtent)
        if let hitResult = hitResults.first {
            force(hitResult, type: .vacuum)
        }
    }
}

// MARK: - Scene View Delegate Methods

extension ViewController : ARSCNViewDelegate {
    
    // this is called every time ARK kit detects a new plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = Plane(planeAnchor, material: selectedPlaneMaterial)
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
    
    // updates the light of the scene based on dynamic light changes
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let light = sceneView.session.currentFrame?.lightEstimate, let _ = lightNode.light {
            lightNode.light?.intensity = light.ambientIntensity
        }
    }
}


// MARK: - Contact Delegate Methods

extension ViewController: SCNPhysicsContactDelegate {
    
    // physics contact handler used if a cube hits the bottom bounds of the world
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.isEqual(bottomPlane) || contact.nodeB.isEqual(bottomPlane) {
            if contact.nodeA.isEqual(bottomPlane) {
                objects.remove(contact.nodeB)
                contact.nodeB.removeFromParentNode()
            } else if contact.nodeB.isEqual(bottomPlane) {
                objects.remove(contact.nodeA)
                contact.nodeA.removeFromParentNode()
            }
        }
    }
}


// MARK: - Button Delegate Methods

extension ViewController {
    
    // segue for options menu
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "optionsSegue" {
            if let nav = segue.destination as? UINavigationController, let vc = nav.topViewController as? OptionsViewController {
                vc.settings = settings
                vc.delegate = self
            }
        }
    }
    
    // when the options button is selected, performs the options segue
    @IBAction func didSelectOptionsButton(_ sender: Any) {
        performSegue(withIdentifier: "optionsSegue", sender: self)
    }
    
    // when the objects button is selected, display the material selection menu
    @IBAction func didSelectObjectsButton(_ sender: Any) {
        pickerMode = .object
        picker.selectRow(materialOptions.index(of: selectedObjectMaterial) ?? 0, inComponent: 0, animated: false)
        pickerView.isHidden = false
    }
    
    // when the planes button is selected, display the material selection menu
    @IBAction func didSelectPlanesButton(_ sender: Any) {
        pickerMode = .plane
        picker.selectRow(materialOptions.index(of: selectedPlaneMaterial) ?? 0, inComponent: 0, animated: false)
        pickerView.isHidden = false
    }
    
    // when the picker done button is selected, hides the picker view
    @IBAction func pickerDoneButtonSelected(_ sender: Any) {
        pickerView.isHidden = true
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


// MARK: - Picker Delegate Methods
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return materialOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return materialOptions[row].rawValue
    }
    
    // when the picker selects a material, sets the appropriate material
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerMode == .object {
            selectedObjectMaterial = materialOptions[row]
        } else if pickerMode == .plane {
            selectedPlaneMaterial = materialOptions[row]
            
            // if the plane material was changed, change all of the existing material as well
            for plane in planes.values {
                plane.planeGeometry?.materials = [Texture(selectedPlaneMaterial)]
                plane.setTextureScale()
            }
        }
    }
}
