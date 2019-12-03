//
//  HomeViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 16/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import EngageSDK
import SSSpinnerButton
import CoreLocation
import Firebase
import FirebaseMessaging

private let uuid = userManager.sdkUuidKey
private let locationManager = CLLocationManager()

class HomeViewController: UIViewController {
    
    var promotions = [ResponseFetchForgroundContent]()
    var isSDKInit: Bool = false
    var refreshControl = UIRefreshControl() {
        didSet {
            refreshControl.tintColor = .white
        }
    }
    var latestBeacon: FilterBeacon?
    var event: ResponseRules?
    var latestlocation: CLLocationCoordinate2D?
    var timer: Timer?
    var autoRefreshContentValue: AutoRefreshContent = userManager.autoRefreshContent
    
    @IBOutlet weak var lblLatLong: UILabel!
    @IBOutlet weak var locationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLoading: SSSpinnerButton! {
        didSet {
            LoadingHelper.shared.showLoading(button: btnLoading, view: [], spinnerType: .circleStrokeSpin, spinnerColor: .red, spinnerSize: 46, complete: nil)
        }
    }
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let attributeTxt = NSMutableAttributedString(string: "Pull to refresh")
            let range: NSRange = attributeTxt.mutableString.range(of: "Pull to refresh", options: .caseInsensitive)
            attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
            attributeTxt.addAttribute(NSAttributedString.Key.font, value: R.font.robotoMedium(size: 15) ?? UIFont.systemFont(ofSize: 15), range: range)
            refreshControl.attributedTitle = attributeTxt
            refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
            tableView.addSubview(refreshControl) // not required when using UITableViewController
        }
    }
    @IBOutlet weak var btnStartAndStop: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(userManager.sdkKey.isEmpty), !(isSDKInit) {
            let initializationRequest = InitializationRequest(apiKey: userManager.sdkKey, appName: "EngageSDK", regionId: "com.proximipro.engageexampleapp", clientId: "16", uuid: userManager.sdkUuidKey)
            let _  =  EngageSDK.init(initData: initializationRequest, onSuccess: {
                // SDK initialized
                self.setupBeaconMonitorBlock()
                self.isSDKInit = true
            }) { (errorMessage) in
                // Error initializing SDK
                LoadingHelper.shared.hideLoding(completionType: .fail, backToDefaults: true, complete: nil)
            }
        } else {
            self.setupBeaconMonitorBlock()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.setUpTimer()
    }
    
    func setUpTimer() {
        if userManager.autoRefreshContentIsOn {
            if userManager.autoRefreshContent != self.autoRefreshContentValue {
                self.initTimer()
                self.autoRefreshContentValue = userManager.autoRefreshContent
            } else if timer == nil {
                self.initTimer()
            }
        } else {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func initTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: userManager.autoRefreshContent.value, target: self, selector: #selector(autoRefreshContent), userInfo: nil, repeats: true)
    }
    
    /// Setup Beacon Monitor Block
    func setupBeaconMonitorBlock() {
        
        guard let manager = EngageSDK.shared else { return }
        manager.onBeaconCamped = { beacon, location in
            print("Entry beacon \(beacon)")
            self.latestBeacon = beacon
            self.latestlocation = location
            self.btnInfo.isHidden = false
            self.callContent(beacon: beacon, location: location)
        }
        manager.onBeaconExit = { beacon, location in
            print("Exit beacon \(beacon)")
            self.latestBeacon = nil
            self.latestlocation = nil
            self.btnInfo.isHidden = true
            self.promotions.removeAll()
            self.tableView.reloadData()
        }
        manager.onRangedBeacon = { beacons in
            print("Ranged beacons \(beacons)")
        }
        manager.onRuleTriggeres = { rule, location in
            print("Rule triggeres \(rule)")
            self.event = rule
            self.latestlocation = location
        }
        manager.onLocationRuleTriggeres = { rule, location in
            print("Location based rule triggeres")
            self.event = rule
            self.latestlocation = location
            self.callLocationContent()
        }
        manager.onPermissionChange = { (message, permission) in
            if !permission {
                self.showAelrt(title: "Permission", message: message)
            }
        }
        manager.locationCheckLiveData = { location in
            if let location = location {
                self.LocationView(show: true, location: location)
            }
            
        }
        DispatchQueue.main.async {
            if !userManager.fcmToken.isEmpty {
                manager.callPushNotificationRegister(pushToken: userManager.fcmToken, responseData: { (response) in
                    // do nothing
                })
            }
        }
    }
    
    @IBAction func btnBeaconInfoClicked(_ sender: Any) {
        if let popupVC = R.storyboard.main.popUpViewController(), let beacon = latestBeacon {
            popupVC.beacon = beacon
            popupVC.event = self.event?.triggerOn ?? ""
            popupVC.modalPresentationStyle = .overCurrentContext
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnStartAndStopClicked(_ sender: UIButton) {
        sender.isEnabled = false
        if !sender.isSelected {
            guard let manager = EngageSDK.shared else { sender.isEnabled = true; return }
            if manager.locationManager == nil {
                manager.locationManager = locationManager
            }
            manager.start { (message, permission) in
                DispatchQueue.main.async {
                    if !(message.isEmpty) {
                        if !permission {
                            self.showAelrt(title: "Permission", message: message)
                            sender.isSelected = false
                            self.showStopData()
                        } else {
                            sender.isSelected = !sender.isSelected
                            self.btnLoading.isHidden = !(sender.isSelected)
                            self.btnInfo.isHidden = self.latestBeacon == nil
                        }
                        sender.isEnabled = true
                    } else {
                        sender.isEnabled = true
                    }
                }
            }
        } else {
            self.showStopData()
            sender.isSelected = !sender.isSelected
            sender.isEnabled = true
        }
    }
    
    func showStopData() {
        guard let manager = EngageSDK.shared else { return }
        manager.stop()
        self.LocationView(show: false, location: nil)
        self.btnLoading.isHidden = true
        self.btnInfo.isHidden = true
    }
    
    func callContent(beacon: FilterBeacon, location: CLLocationCoordinate2D?) {
        guard let manager = EngageSDK.shared else { return }
        manager.callFetchForgroundContentApi(uuid: beacon.beacon.proximityUUID.uuidString, major: beacon.beacon.major.stringValue, minor: beacon.beacon.minor.stringValue, latitude: location?.latitude.description ?? "", longitude: location?.longitude.description ?? "") { (response) in
            if let response = response {
                print(response)
                self.promotions = response
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func callLocationContent() {
        guard let manager = EngageSDK.shared else { return }
        manager.callFetchForgroundContentApi(location: latestlocation) { (response) in
            if let response = response {
                print(response)
                self.promotions = response
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refresh(sender: AnyObject) {
        self.autoRefreshContent()
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func btnSettingClicked(_ sender: Any) {
        if let settingVc = R.storyboard.main.settingsViewController() {
            self.navigationController?.pushViewController(settingVc, animated: true)
        }
    }
    
    @IBAction func btnProfileClicked(_ sender: Any) {
        if let profileVc = R.storyboard.main.profileViewController() {
            self.navigationController?.pushViewController(profileVc, animated: true)
        }
    }
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        self.logoutAlert()
    }
    
    @objc func autoRefreshContent() {
        if self.latestlocation != nil {
            self.callLocationContent()
        } else if let beacon = self.latestBeacon {
            self.callContent(beacon: beacon, location: self.latestlocation)
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.promotions.count == 0 ? 1 : self.promotions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.promotions.count > 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.homeTableViewCell, for: indexPath) else { return UITableViewCell() }
            cell.loadContent(data: promotions[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCell, for: indexPath) else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.promotions.count > 0 ? 300 : (UIScreen.main.bounds.height - 120)
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.promotions.count > 0 else { return }
        if let detailVc = R.storyboard.main.detailViewController() {
            detailVc.content = self.promotions[indexPath.row]
            detailVc.beacon = self.latestBeacon
            detailVc.location = self.latestlocation
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
    
}

extension HomeViewController {
    
    func showAelrt(title: String, message: String) {
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let alertController = UIAlertController.showAlert(title: title, message: message, actions: [settingsAction], preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logoutAlert() {
        let yes = UIAlertAction.init(title: "Yes", style: .destructive) { (action) in
            self.logoutAction()
        }
        let no = UIAlertAction.init(title: "No", style: .default) { (action) in
            
        }
        let alertController = UIAlertController.showAlert(title: "Logout", message: "Are you sure you want to log out?", actions: [yes, no], preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logoutAction() {
        guard let manager = EngageSDK.shared else { return }
        if btnStartAndStop.isSelected {
            manager.stop()
            self.latestBeacon = nil
            self.event = nil
            self.latestlocation = nil
            self.promotions.removeAll()
            self.btnInfo.isHidden = true
            self.tableView.reloadData()
        }
        manager.clearSDKData()
        userManager.clearAllData()
        InstanceID.instanceID().deleteID { (error) in
            if error == nil {
                print("Token deleted from server")
            }else {
                print("Error == ", error ?? "Token not deleted")
            }
            
        }
        if let loginNav = R.storyboard.main.loginNav() {
            DispatchQueue.main.async {
                loginNav.changeRootViewWithAnimation(success: nil)
            }
        }
    }
}

// MARK:- Campaign notification
extension HomeViewController {
    
    func notificationAlert(userData: [AnyHashable: Any]) {
        let yes = UIAlertAction.init(title: "Accept", style: .default) { (action) in
            if let url = userData[NotificationApi.url.rawValue] as? String {
                self.callNotificationContent(url: url)
            }
            if let id = userData[NotificationApi.campaign.rawValue] as? String {
                self.callPushLogAPI(id: id)
            }
        }
        let no = UIAlertAction.init(title: "Cancle", style: .cancel) { (action) in
            
        }
        if let title = userData[NotificationApi.title.rawValue] as? String, let message = userData[NotificationApi.message.rawValue] as? String {
            let alertController = UIAlertController.showAlert(title:  title, message:  message, actions: [no, yes], preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func callPushLogAPI(id: String) {
        guard let manager = EngageSDK.shared else { return }
        manager.callLogPushNotification(notificationId: id, action: "open") { (response) in
            print(response ?? "")
        }
    }
    
    func callNotificationContent(url: String) {
        guard let manager = EngageSDK.shared else { return }
        manager.callFetchForgroundContentApiForForgroundNotification(url: url) { (response) in
            if let response = response {
                print(response)
                self.promotions = response
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - LocationView
extension HomeViewController {
    
    func LocationView(show: Bool, location: CLLocationCoordinate2D?) {
        self.locationViewHeightConstraint.constant = show ? 30 : 0
        if let location  = location {
            self.lblLatLong.text = location.latitude.description + " , " + location.longitude.description
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
