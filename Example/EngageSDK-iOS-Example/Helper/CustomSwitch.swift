//
//  CustomSwitch.swift
//  1Loop
//
//  Created by ProximiPRO on 07/05/19.
//  Copyright © 2019 SimformSolutions. All rights reserved.
//

import UIKit

class CustomSwitch: UISwitch {
    
    @IBInspectable var roundCorner: Bool {
        get {
            return true
        }
        set {
            layer.cornerRadius = self.frame.height / 2
            layer.masksToBounds = newValue
        }
    }
}
