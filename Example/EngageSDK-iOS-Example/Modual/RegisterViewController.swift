//
//  ViewController.swift
//  EngageSDK
//
//  Created by ProximiPRO on 13/08/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import EngageSDK
import SSSpinnerButton

///  ViewController
class RegisterViewController: UIViewController {
    
    @IBOutlet weak var txtEnterYourBirthDate: CustomTextField! {
        didSet {
            let iVar = class_getInstanceVariable(UITextField.self, "_placeholderLabel")!
            let placeholderLabel = object_getIvar(txtEnterYourBirthDate, iVar) as! UILabel
            placeholderLabel.textColor = .white
        }
    }
    @IBOutlet var btnGender: [UIButton]!
    @IBOutlet weak var btnSignup: SSSpinnerButton!
    
    let datePickerView = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        datePickerView.datePickerMode = .date
        txtEnterYourBirthDate.inputAccessoryView = toolbar
        txtEnterYourBirthDate .inputView = datePickerView
        datePickerView.maximumDate = Date()
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        txtEnterYourBirthDate.text = formatter.string(from: datePickerView.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
     }
    
    @IBAction func btnGenderClicked(_ sender: UIButton) {
        self.btnGender.forEach({
            $0.isSelected = $0.tag == sender.tag
        })
        
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        txtEnterYourBirthDate.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func btnSignUpClicked(_ sender: Any) {
        if let text = txtEnterYourBirthDate.text, !(text.isEmpty), let manager = EngageSDK.shared, let gender = self.btnGender.filter({return $0.isSelected}).first?.titleLabel?.text {
            LoadingHelper.shared.showLoading(button: btnSignup, view: [self.view]) {
                manager.callRegisterUserApi(birthDate: text, gender: gender, tags: nil) { (response) in
                    if let _ = response {
                        // sucess
                        LoadingHelper.shared.hideLoding(complete: {
                            if let interestController = R.storyboard.main.yourInterestsViewController() {
                                self.navigationController?.pushViewController(interestController, animated: true)
                            }
                        })
                    } else {
                        // Fail
                        LoadingHelper.shared.hideLoding(completionType: .fail, backToDefaults: true, complete: nil)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func btnTermsAndCondtionsClicked(_ sender: Any) {
        
        if let url = URL(string: ProximiProApp.termsAndConditionsURL) {
            UIApplication.shared.open(url)
        }
    }
    
}
