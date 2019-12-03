//
//  LodingHelper.swift
//  ServiceHub
//
//  Created by ProximiPRO on 12/12/18.
//  Copyright © 2018 SimformSolutions. All rights reserved.
//

import UIKit
import SSSpinnerButton

class LoadingHelper: NSObject {
    
    static let shared = LoadingHelper()
    var view: [UIView]?
    var button: SSSpinnerButton?
    
    func showLoading(button: SSSpinnerButton, view: [UIView], spinnerType: SpinnerType = .circleStrokeSpin, spinnerColor: UIColor = .white, spinnerSize: UInt = 20, complete: (() -> Void)?) {
        LoadingHelper.shared.onOld()
        LoadingHelper.shared.button = button
        LoadingHelper.shared.view = view
        view.forEach {
            $0.isUserInteractionEnabled = false
        }
        button.startAnimate(spinnerType: spinnerType, spinnercolor: spinnerColor, spinnerSize: spinnerSize, complete: complete)
    }
    
    
    func hideLoding(completionType: CompletionType = .success, backToDefaults: Bool = true, complete: (() -> Void)?) {
        
        
        if let button = LoadingHelper.shared.button {
            button.stopAnimationWithCompletionTypeAndBackToDefaults(completionType: completionType, backToDefaults: backToDefaults) {
                if let view = LoadingHelper.shared.view {
                    view.forEach {
                        $0.isUserInteractionEnabled = true
                    }
                }
                guard let block = complete else {
                    return
                }
                block()
            }
        }
        
    }
        
        
    
    func onOld() {
        if let view = LoadingHelper.shared.view {
            
            let _ = view.filter {
                $0.isUserInteractionEnabled = true
                return false
            }
            
        }
    }
    
}
