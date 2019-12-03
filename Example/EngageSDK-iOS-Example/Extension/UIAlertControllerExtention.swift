//
//  UIAlertControllerExtention.swift
//  ServiceHub
//
//  Created by ProximiPRO on 07/12/18.
//  Copyright © 2018 SimformSolutions. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func showAlert(title: String?, message: String?, actions: [UIAlertAction], preferredStyle: UIAlertController.Style, addTextFieldConfigurationHandler: ((UITextField) -> Void)? = nil) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            controller.addAction(action)
        }
        if let addTextFieldConfigurationHandler = addTextFieldConfigurationHandler {
            controller.addTextField(configurationHandler: addTextFieldConfigurationHandler)
        }
        return controller
    }
    
}
