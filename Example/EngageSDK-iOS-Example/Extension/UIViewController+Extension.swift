//
//  UIViewController+Extension.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 30/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar

extension UIViewController {
    
    func showSnakBar(message: String) {
        let action = MDCSnackbarMessageAction()
        let answerMessage = MDCSnackbarMessage(text: message)
        let actionHandler = { () in
            
        }
        action.handler = actionHandler
        action.title = "OK"
        answerMessage.action = action
        MDCSnackbarManager.show(answerMessage)
    }
    
}
