//
//  ProfileViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 17/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import SSSpinnerButton
import EngageSDK
import MaterialComponents.MaterialSnackbar

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var txtEnterYourBirthDate: CustomTextField!
    @IBOutlet var btnGender: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSaveChanges: SSSpinnerButton!
    private var tags = EngageSDK.shared?.userInfo?.tags ?? [Tag]()
    let datePickerView = UIDatePicker()
    var isEdit: Bool {
        get {
            return !self.btnSaveChanges.isHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let manager = EngageSDK.shared {
            self.btnGender.forEach({
                $0.isSelected = $0.titleLabel?.text?.lowercased() == manager.userInfo?.gender?.lowercased()
            })
            self.txtEnterYourBirthDate.text = manager.userInfo?.birthDate
        }
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
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        txtEnterYourBirthDate.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEditClicked(_ sender: Any) {
        self.btnSaveChanges.isHidden = !self.btnSaveChanges.isHidden
        self.tableView.reloadData()
    }
    
    @IBAction func btnGenderClicked(_ sender: UIButton) {
        guard isEdit else {
            return
        }
        self.btnGender.forEach({
            $0.isSelected = $0.tag == sender.tag
        })
    }
    
    @IBAction func btnSaveChangesClicked(_ sender: Any) {
        if let text = txtEnterYourBirthDate.text, !(text.isEmpty), let manager = EngageSDK.shared, let gender = self.btnGender.filter({return $0.isSelected}).first?.titleLabel?.text {
            LoadingHelper.shared.showLoading(button: btnSaveChanges, view: [self.view]) {
                manager.callUpdateUserApi(birthDate: text, gender: gender, tags: self.tags) { (response) in
                    if let response = response {
                        // sucess
                        print(response)
                        LoadingHelper.shared.hideLoding(complete: {
                            self.btnSaveChanges.isHidden = true
                            self.showSnakBar(message: "Profile updated")
                        })
                    } else {
                        // Fail
                        LoadingHelper.shared.hideLoding(completionType: .fail, backToDefaults: true, complete: {
                            self.showSnakBar(message: "Profile not updated")
                        })
                    }
                }
            }
            
        }
        
    }
    
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.interestsTableViewCell, for: indexPath) else {
            return UITableViewCell()
        }
        cell.lblTitle.text = tags[indexPath.row].name
        cell.selectionStyle = .none
        cell.imgCheckMark?.isHighlighted = self.tags[indexPath.row].isSelected ?? false
        cell.imgCheckMark?.tintColor = isEdit ? .red : .gray
        return cell
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isEdit else {
            return
        }
        if self.tags.count > 0 {
            self.tags[indexPath.row].isSelected = !(self.tags[indexPath.row].isSelected ?? true)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEdit
    }
    
}
