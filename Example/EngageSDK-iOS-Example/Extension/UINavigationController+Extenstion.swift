//
//  UINavigationController+Extension.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 17/09/19.
//  Copyright © 2019 SimformSolutions. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    public func changeRootViewWithAnimation(success: Success?) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController {
            rootViewController.dismiss(animated: false, completion: nil)
            self.view.frame = rootViewController.view.frame
            self.view.layoutIfNeeded()
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = self
                
            }, completion: { completed in
                // maybe do something here
                success?()
            })
        }
    }
    
}
