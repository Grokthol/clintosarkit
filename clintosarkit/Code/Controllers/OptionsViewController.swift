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
    
    @IBOutlet weak var originSwitch: UISwitch!
    @IBOutlet weak var pointSwitch: UISwitch!
    @IBOutlet weak var statisticsSwitch: UISwitch!
    @IBOutlet weak var lightingSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializes the view to match the settings
        if let settings = settings {
            originSwitch.isOn = settings.displayWorldOrigin
            pointSwitch.isOn = settings.displayFeaturePoints
            statisticsSwitch.isOn = settings.displayStatistics
            lightingSwitch.isOn = settings.enableDefaultLighting
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
            settings?.displayFeaturePoints = originSwitch.isOn
        } else if sender.isEqual(statisticsSwitch) {
            settings?.displayStatistics = statisticsSwitch.isOn
        } else if sender.isEqual(lightingSwitch) {
            settings?.enableDefaultLighting = lightingSwitch.isOn
        }
        delegate?.modifiedSettings(settings)
    }
    
    // dismisses the view when the user is done
    @IBAction func didSelectDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
