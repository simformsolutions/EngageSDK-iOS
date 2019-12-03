//
//  YourInterestsViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 14/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import SSSpinnerButton
import EngageSDK

class YourInterestsViewController: UIViewController {
    
    @IBOutlet weak var btnImDone: SSSpinnerButton!
    @IBOutlet weak var tableView: UITableView!
    private var tags: [Tag] = EngageSDK.shared?.userInfo?.tags ?? [Tag]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnImDoneClicked(_ sender: Any) {
        guard let manager = EngageSDK.shared else { return }
        LoadingHelper.shared.showLoading(button: btnImDone, view: [self.view]) {
            manager.callUpdateUserApi(birthDate: nil, gender: nil, tags: self.tags) { (response) in
                if let response = response {
                    // sucess
                    print(response)
                    userManager.isUserLogin = true
                    LoadingHelper.shared.hideLoding(complete: {
                        if let homeNav = R.storyboard.main.homeNav() {
                            if let homeVC = homeNav.viewControllers.first as? HomeViewController {
                                homeVC.isSDKInit = true
                            }
                            homeNav.changeRootViewWithAnimation(success: nil)
                        }
                    })
                } else {
                    // fail
                    LoadingHelper.shared.hideLoding(completionType: .fail, backToDefaults: true, complete: nil)
                }
            }
        }
        print(tags)
    }
    
}

extension YourInterestsViewController: UITableViewDataSource {
    
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
        return cell
    }
    
}

extension YourInterestsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tags.count > 0 {
            self.tags[indexPath.row].isSelected = !(self.tags[indexPath.row].isSelected ?? true)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
}
