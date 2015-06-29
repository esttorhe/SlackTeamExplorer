//
//  UIColors_Slack.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

import UIKit

extension UIColor {
    static func slackPurpleColor() -> UIColor {
        return UIColor(hue: 0.732, saturation: 0.64, brightness: 0.435, alpha: 1.0)
    }
    
    static func slackLightBlueColor() -> UIColor {
        return UIColor(hue:0.613, saturation:0.718, brightness:0.988, alpha:1.0)
    }
    
    static func slackLightGreyColor() -> UIColor {
        return UIColor(hue:0, saturation:0, brightness:0.875, alpha:1.0)
    }
    
    static func slackDarkGreyColor() -> UIColor {
        return UIColor(hue:0.602, saturation:0.36, brightness:0.196, alpha:1.0)
    }
}