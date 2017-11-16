//
//  OptionsViewController.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-14.
//  Copyright © 2017 Clinton. All rights reserved.
//

import UIKit

// a delegate for letting any listeners know when the settings have been changed
protocol OptionsDelegate: class {
    func modifiedSettings(_ settings: Settings?)
}

// a class for displaying and modifying settings
class OptionsViewController: UITableViewController {
    
    var settings: Settings?
    weak var delegate: OptionsDelegate?
    
    // material selection options
    let materialOptions = [MaterialType.none, MaterialType.copper, MaterialType.iron,
                           MaterialType.limestone, MaterialType.sandstone, MaterialType.rubber,
                           MaterialType.plastic]
    
    @IBOutlet weak var originSwitch: UISwitch!
    @IBOutlet weak var pointSwitch: UISwitch!
    @IBOutlet weak var statisticsSwitch: UISwitch!
    @IBOutlet weak var lightingSwitch: UISwitch!
    @IBOutlet weak var forceSlider: UISlider!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var objectPicker: UIPickerView!
    @IBOutlet weak var planePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializes the view to match the settings
        if let settings = settings {
            originSwitch.isOn = settings.displayWorldOrigin
            pointSwitch.isOn = settings.displayFeaturePoints
            statisticsSwitch.isOn = settings.displayStatistics
            lightingSwitch.isOn = settings.enableDefaultLighting
            forceSlider.value = settings.force
            sizeSlider.value = settings.size
        }
    }
}


// MARK: - Actions

extension OptionsViewController {
    
    // if a setting switch was toggled, sets the appropriate settings value
    @IBAction func toggled(_ sender: UISwitch) {
        if sender.isEqual(originSwitch) {
            settings?.displayWorldOrigin = originSwitch.isOn
        } else if sender.isEqual(pointSwitch) {
            settings?.displayFeaturePoints = pointSwitch.isOn
        } else if sender.isEqual(statisticsSwitch) {
            settings?.displayStatistics = statisticsSwitch.isOn
        } else if sender.isEqual(lightingSwitch) {
            settings?.enableDefaultLighting = lightingSwitch.isOn
        }
        delegate?.modifiedSettings(settings)
    }
    
    // when a slider value changes, set the appropriate settings value
    @IBAction func sliderChanged(_ sender: UISlider) {
        if sender.isEqual(forceSlider) {
            settings?.force = sender.value
        } else if sender.isEqual(sizeSlider) {
            settings?.size = sender.value
        }
        delegate?.modifiedSettings(settings)
    }
    
    // dismisses the view when the user is done
    @IBAction func didSelectDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Picker Delegate Methods

extension OptionsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        if pickerView == objectPicker {
            settings?.objectMaterial = materialOptions[row]
        } else if pickerView == planePicker {
            settings?.planeMaterial = materialOptions[row]
        }
        
        delegate?.modifiedSettings(settings)
    }
}

