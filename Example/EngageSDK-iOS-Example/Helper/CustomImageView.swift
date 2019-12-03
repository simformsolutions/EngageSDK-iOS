//
//  CustomImageView.swift
//  1Loop
//
//  Created by ProximiPRO on 03/05/19.
//  Copyright © 2019 SimformSolutions. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
