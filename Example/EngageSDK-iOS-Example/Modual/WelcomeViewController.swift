//
//  WelcomeViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 14/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import EngageSDK
import SSSpinnerButton

class WelcomeViewController: UIViewController {

    @IBOutlet weak var txtEnterApiKey: CustomTextField! {
        didSet {
            let iVar = class_getInstanceVariable(UITextField.self, "_placeholderLabel")!
            let placeholderLabel = object_getIvar(txtEnterApiKey, iVar) as! UILabel
            placeholderLabel.textColor = .white
        }
    }
    @IBOutlet weak var btnSubmit: SSSpinnerButton!
    @IBOutlet weak var btnSeePlatformOptions: SSSpinnerButton!
    @IBOutlet weak var btnTryNow: SSSpinnerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        if let apiKey = self.txtEnterApiKey.text, !(apiKey.isEmpty) {
          self.initSDK(apiKey: apiKey)
        }
    }
    
    func initSDK(apiKey: String) {
        LoadingHelper.shared.showLoading(button: btnSubmit, view: [self.view]) {
            let initializationRequest = InitializationRequest(apiKey: apiKey, appName: "EngageSDK", regionId: "com.proximipro.engageexampleapp", clientId: "16", uuid: userManager.sdkUuidKey)
            let _  =  EngageSDK.init(initData: initializationRequest, onSuccess: {
                // SDK initialized
                userManager.sdkKey = apiKey
                LoadingHelper.shared.hideLoding(complete: {
                    if let registerController = R.storyboard.main.registerViewController() {
                        self.navigationController?.pushViewController(registerController, animated: true)
                    }
                })
            }) { (errorMessage) in
                // Error initializing SDK
                LoadingHelper.shared.hideLoding(completionType: .fail, backToDefaults: true, complete: nil)
            }
        }
    }
    
    @IBAction func btnSeePlatformOptionsClicked(_ sender: Any) {
        if let url = URL(string: ProximiProApp.homepage) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func btnTryNowClicked(_ sender: Any) {
        self.initSDK(apiKey: ProximiProApp.sdkApiKey)
    }
    
}
