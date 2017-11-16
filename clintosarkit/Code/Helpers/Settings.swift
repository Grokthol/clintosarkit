//
//  Settings.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-14.
//  Copyright © 2017 Clinton. All rights reserved.
//

import UIKit

class Settings {
    var displayWorldOrigin: Bool = false
    var displayFeaturePoints: Bool = false
    var displayStatistics: Bool = false
    var size: Float = 0.5
    var force: Float = 0.5
    var objectMaterial: MaterialType = .none
    var planeMaterial: MaterialType = .none
    var enableDefaultLighting: Bool = true
    var enableDynamicLighting: Bool = false
    var lightColor: UIColor = UIColor.white
}
