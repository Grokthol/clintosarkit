//
//  ColorSlider.swift
//  clintosarkit
//
//  Created by Clinton on 2017-11-16.
//  Copyright © 2017 Clinton. All rights reserved.
//

import UIKit

// a slider, that converts its values to colors
class ColorSlider: UISlider {
    
    // converts a value between 0 and 14 into a color
    func colorForValue(_ value: Float) -> UIColor {
        
        if value >= 0 && value < 1 {
            // black
            return UIColor.black
        } else if value >= 1 && value < 2 {
            // red
            return UIColor.hackRed
        } else if value >= 2 && value < 3 {
            // dark orange
            return UIColor.hackDarkOrange
        } else if value >= 3 && value < 4 {
            // light orange
            return UIColor.hackLightOrange
        } else if value >= 4 && value < 5 {
            // orange / yellow
            return UIColor.hackOrangeYellow
        } else if value >= 5 && value < 6 {
            // yellow
            return UIColor.hackYellow
        } else if value >= 6 && value < 7 {
            // neon green
            return UIColor.hackNeonGreen
        } else if value >= 7 && value < 8 {
            // green
            return UIColor.hackGreen
        } else if value >= 8 && value < 9 {
            // turqoise
            return UIColor.hackTurqoise
        } else if value >= 9 && value < 10 {
            // blue
            return UIColor.hackBlue
        } else if value >= 10 && value < 11 {
            // purple
            return UIColor.hackPurple
        } else if value >= 11 && value < 12 {
            // other purple
            return UIColor.hackOtherPurple
        } else if value >= 12 && value < 13 {
            // other other purple
            return UIColor.hackOtherOtherPurple
        }
        
        // if all else fails, return white
        return UIColor.white
    }
    
    // converts a value into a color between 0 and 14
    func valueForColor(_ color: UIColor) -> Float {
        
        switch (color) {
        case UIColor.black:
            return 0.5
        case UIColor.hackRed:
            return 1.5
        case UIColor.hackDarkOrange:
            return 2.5
        case UIColor.hackLightOrange:
            return 3.5
        case UIColor.hackOrangeYellow:
            return 4.5
        case UIColor.hackYellow:
            return 5.5
        case UIColor.hackNeonGreen:
            return 6.5
        case UIColor.hackGreen:
            return 7.5
        case UIColor.hackTurqoise:
            return 8.5
        case UIColor.hackBlue:
            return 9.5
        case UIColor.hackPurple:
            return 10.5
        case UIColor.hackOtherPurple:
            return 11.5
        case UIColor.hackOtherOtherPurple:
            return 12.5
        case UIColor.white:
            return 13.5
        default:
            return 14
        }
    }
}
