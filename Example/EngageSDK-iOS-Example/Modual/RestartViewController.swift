//
//  RestartViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 11/10/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit

class RestartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.switchToHomeScreen(success: nil)
    }
    
    func switchToHomeScreen(success: Success?) {
        DispatchQueue.delay(bySeconds: 3) {
            if userManager.isUserLogin, let homeNav = R.storyboard.main.homeNav() {
                homeNav.changeRootViewWithAnimation(success: success)
            } else if let welcomeNav = R.storyboard.main.loginNav() {
                welcomeNav.changeRootViewWithAnimation(success: success)
            }
        }
    }
    
}
