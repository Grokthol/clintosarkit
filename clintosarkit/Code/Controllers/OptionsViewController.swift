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
    
    @IBOutlet weak var dynamicLightingLabel: UILabel!
    
    @IBOutlet weak var originSwitch: UISwitch!
    @IBOutlet weak var pointSwitch: UISwitch!
    @IBOutlet weak var statisticsSwitch: UISwitch!
    @IBOutlet weak var forceSlider: UISlider!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var objectPicker: UIPickerView!
    @IBOutlet weak var planePicker: UIPickerView!
    @IBOutlet weak var defaultLightingSwitch: UISwitch!
    @IBOutlet weak var dynamicLightingSwitch: UISwitch!
    @IBOutlet weak var colorSlider: ColorSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializes the view to match the settings
        if let settings = settings {
            
            // debug
            originSwitch.isOn = settings.displayWorldOrigin
            pointSwitch.isOn = settings.displayFeaturePoints
            statisticsSwitch.isOn = settings.displayStatistics
            
            // sliders
            forceSlider.value = settings.force
            sizeSlider.value = settings.size
            
            // material pickers
            objectPicker.selectRow(materialOptions.index(of: settings.objectMaterial) ?? 0, inComponent: 0, animated: false)
            planePicker.selectRow(materialOptions.index(of: settings.planeMaterial) ?? 0, inComponent: 0, animated: false)
            
            // lighting
            defaultLightingSwitch.isOn = settings.enableDefaultLighting
            dynamicLightingSwitch.isEnabled = !defaultLightingSwitch.isOn
            dynamicLightingLabel.isEnabled = dynamicLightingSwitch.isEnabled
            dynamicLightingSwitch.isOn = settings.enableDynamicLighting
            colorSlider.isEnabled = !defaultLightingSwitch.isOn
            colorSlider.value = colorSlider.valueForColor(settings.lightColor)
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
        } else if sender.isEqual(defaultLightingSwitch) {
            settings?.enableDefaultLighting = defaultLightingSwitch.isOn
            
            // toggles the dynamic switch depending on the value of the default switch
            dynamicLightingSwitch.isEnabled = !defaultLightingSwitch.isOn
            dynamicLightingLabel.isEnabled = dynamicLightingSwitch.isEnabled
            if dynamicLightingSwitch.isOn {
                dynamicLightingSwitch.setOn(false, animated: true)
                toggled(dynamicLightingSwitch)
            }
            
            // toggles the light color depending on the value of the default switch
            colorSlider.isEnabled = !defaultLightingSwitch.isOn
            if defaultLightingSwitch.isOn {
                colorSlider.value = colorSlider.valueForColor(UIColor.white)
                settings?.lightColor = UIColor.white
            }
            
        } else if sender.isEqual(dynamicLightingSwitch) {
            settings?.enableDynamicLighting = dynamicLightingSwitch.isOn
        }
        delegate?.modifiedSettings(settings)
    }
    
    // when a slider value changes, set the appropriate settings value
    @IBAction func sliderChanged(_ sender: UISlider) {
        if sender.isEqual(forceSlider) {
            settings?.force = sender.value
        } else if sender.isEqual(sizeSlider) {
            settings?.size = sender.value
        } else if sender.isEqual(colorSlider) {
            settings?.lightColor = colorSlider.colorForValue(colorSlider.value)
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

