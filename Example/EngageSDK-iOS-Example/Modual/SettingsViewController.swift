//
//  SettingsViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 17/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import EngageSDK
import MaterialComponents.MaterialSnackbar

enum EditKeys {
    case apiKey
    case uuid
}

enum AutoRefreshContent: String, CaseIterable {
    case tenSeconds = "10 seconds"
    case thirtySeconds = "30 seconds"
    case sixtySeconds = "60 seconds"
    
    var value: TimeInterval {
        switch self {
        case .tenSeconds:
            return 10
        case .thirtySeconds:
            return 30
        case .sixtySeconds:
            return 60
        }
    }
}

enum AutoRefreshContentInMinutes: String, CaseIterable {
    case noSnooze = "No Snooze"
    case oneMinutes = "1 Minutes"
    case fiveMinutes = "5 Minutes"
    case fifteenMinutes = "15 Minutes"
    case thirtyMinutes = "30 Minutes"
    case sixtyMinutes = "60 Minutes"
    
    var value: Double {
        switch self {
        case .noSnooze:
            return 0
        case .oneMinutes:
            return 1
        case .fiveMinutes:
            return 5
        case .fifteenMinutes:
            return 15
        case .thirtyMinutes:
            return 30
        case .sixtyMinutes:
            return 60
        }
    }
    
    static func getEnum(value: Double) -> AutoRefreshContentInMinutes {
        switch value {
        case AutoRefreshContentInMinutes.noSnooze.value:
            return .noSnooze
        case AutoRefreshContentInMinutes.oneMinutes.value:
            return .oneMinutes
        case AutoRefreshContentInMinutes.fiveMinutes.value:
            return .fiveMinutes
        case AutoRefreshContentInMinutes.fifteenMinutes.value:
            return .fifteenMinutes
        case AutoRefreshContentInMinutes.thirtyMinutes.value:
            return .thirtyMinutes
        case AutoRefreshContentInMinutes.sixtyMinutes.value:
            return .sixtyMinutes
        default:
            return .noSnooze
        }
    }
    
}

enum TxPower: String, CaseIterable {
    case seventySevenDbm = "-77 dBm"
    case seventyTwoDmb = "-72 dBm"
    case sixtyNineDmb = "-69 dBm"
    case sixtyFiveDmb = "-65 dBm"
    case fiftyNineDmb = "-59 dBm"
    
    var value: Double {
        switch self {
        case .seventySevenDbm:
            return -77
        case .seventyTwoDmb:
            return -72
        case .sixtyNineDmb:
            return -69
        case .sixtyFiveDmb:
            return -65
        case .fiftyNineDmb:
            return -59
        }
    }
    
    static func getEnum(value: Double) -> TxPower {
        switch value {
        case TxPower.seventySevenDbm.value:
            return .seventySevenDbm
        case TxPower.seventyTwoDmb.value:
            return .seventyTwoDmb
        case TxPower.sixtyNineDmb.value:
            return .sixtyNineDmb
        case TxPower.sixtyFiveDmb.value:
            return .sixtyFiveDmb
        case TxPower.fiftyNineDmb.value:
            return .fiftyNineDmb
        default:
            return .fiftyNineDmb
        }
    }
    
}

enum AutoRefreshContentInHours: String, CaseIterable {
    case noSnooze = "No Snooze"
    case oneHours = "1 Hours"
    case twoHours = "2 Hours"
    case fourHours = "4 Hours"
    case sixHours = "6 Hours"
    case twelveHours = "12 Hours"
    case twentyFourHours = "24 Hours"
    
    var value: Double {
        switch self {
        case .noSnooze:
            return 0
        case .oneHours:
            return 1
        case .twoHours:
            return 2
        case .fourHours:
            return 4
        case .sixHours:
            return 6
        case .twelveHours:
            return 12
        case .twentyFourHours:
            return 24
        }
    }
    
    static func getEnum(value: Double) -> AutoRefreshContentInHours {
        switch value {
        case AutoRefreshContentInHours.noSnooze.value:
            return .noSnooze
        case AutoRefreshContentInHours.oneHours.value:
            return .oneHours
        case AutoRefreshContentInHours.twoHours.value:
            return .twoHours
        case AutoRefreshContentInHours.fourHours.value:
            return .fourHours
        case AutoRefreshContentInHours.sixHours.value:
            return .sixHours
        case AutoRefreshContentInHours.twelveHours.value:
            return .twelveHours
        case AutoRefreshContentInHours.twentyFourHours.value:
            return .twentyFourHours
        default:
            return .noSnooze
        }
    }
    
}

class SettingsViewController: UITableViewController {
    
    private var sectionHeader = ["General", "Background Scan", "Auto Refresh", "Content Loading", "Notifications", "Beacon Power"]
    private var rawTitle = [["ProximiPRO API Key\n", "iBeacon UUID\n"], ["Background Mode\n", "Notifications\n"], ["Auto Refresh Content\n", "Auto Refresh Interval\n"], ["Location Based Content\n"], ["Snooze Notification\n", "Snooze Content\n"], ["Tx Power\n"]]
    private var rawDeatil = [["Enable/disable background scan mode", "Enable/disable notification went the app is running in background"], ["Enable/disable auto refresh content when a scan is ongoing", "10 seconds"], ["Enable/disable location based content loading feature"], ["No Snooze", "No Snooze"], ["-59 dBm"]]
    private let images = [[R.image.apiKey() ?? UIImage(), R.image.beaconUUID() ?? UIImage()], [R.image.backgroundModelOff() ?? UIImage(), R.image.notificationsOff() ?? UIImage()], [R.image.autorefreshContent() ?? UIImage(), R.image.autoRefreshInterval() ?? UIImage()], [R.image.locationOn() ?? UIImage()], [R.image.snoozeNotification() ?? UIImage(), R.image.snoozeContentOff() ?? UIImage()], [R.image.powerIcon() ?? UIImage()]]
    
    private var apiKey = userManager.sdkKey
    private let sdkUUID = userManager.sdkUuidKey
    var alertTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    
}

extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionHeader.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 || section == 5 {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.primaryTableViewCell, for: indexPath) else { return UITableViewCell() }
            cell.imgIcon.image = images[indexPath.section][indexPath.row]
            let title = rawTitle[indexPath.section][indexPath.row]
            switch indexPath.row {
            case 0:
                cell.lblTitle.text = "\(title)\(userManager.sdkKey)"
            default:
                cell.lblTitle.text = "\(title)\(userManager.sdkUuidKey)"
            }
            cell.lblTitle.highlight(searchedText: rawTitle[indexPath.section][indexPath.row], color: .white)
            cell.selectionStyle = .none
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.secondryTableViewCell, for: indexPath) else { return UITableViewCell() }
            cell.imgIcon.image = images[indexPath.section][indexPath.row]
            let title = rawTitle[indexPath.section][indexPath.row]
            cell.lblTitle.text = "\(title)\(rawDeatil[indexPath.section-1][indexPath.row])"
            cell.onOffSwitch.isHidden = false
            guard let manager = EngageSDK.shared else { return UITableViewCell() }
            switch indexPath.section {
            case 1:
                switch indexPath.row {
                case 0:
                    cell.onOffSwitch.isOn = manager.isBackgroundMode
                    cell.imgIcon.image = manager.isBackgroundMode ? R.image.backgroundModelOn() ?? UIImage() : images[indexPath.section][indexPath.row]
                case 1:
                    cell.onOffSwitch.isOn = manager.isNotificationEnabled
                    cell.imgIcon.image = manager.isNotificationEnabled ? R.image.notificationOn() ?? UIImage() : images[indexPath.section][indexPath.row]
                    cell.onOffSwitch.isEnabled = manager.isBackgroundMode
                default:
                    break
                }
            case 2:
                switch indexPath.row {
                case 0:
                    cell.onOffSwitch.isOn = userManager.autoRefreshContentIsOn
                    cell.imgIcon.image =  images[indexPath.section][indexPath.row]
                case 1:
                    cell.lblTitle.text = "\(title)\(userManager.autoRefreshContent.rawValue)"
                    cell.onOffSwitch.isHidden = true
                default:
                    break
                }
            case 3:
                switch indexPath.row {
                case 0:
                    cell.onOffSwitch.isOn = manager.isLocationBasedContentEnabled
                    cell.imgIcon.image = manager.isLocationBasedContentEnabled ? images[indexPath.section][indexPath.row] : R.image.backgroundModelOff() ?? UIImage()
                default:
                    break
                }
            case 4:
                cell.onOffSwitch.isHidden = true
                switch indexPath.row {
                case 0:
                    cell.lblTitle.text = "\(title)" + AutoRefreshContentInMinutes.getEnum(value: manager.snoozeNotificationTimeInMinutes).rawValue
                case 1:
                    cell.imgIcon.image = manager.snoozeContentTimeInHours > 0 ? R.image.snoozeContentOn() ?? UIImage() : images[indexPath.section][indexPath.row]
                    cell.lblTitle.text = "\(title)" + AutoRefreshContentInHours.getEnum(value: manager.snoozeContentTimeInHours).rawValue
                default:
                    break
                }
            case 5:
                cell.onOffSwitch.isHidden = true
                switch indexPath.row {
                case 0:
                    cell.lblTitle.text = "\(title)" + TxPower.getEnum(value: manager.txPower).rawValue
                default:
                    break
                }
            default:
                break
            }
            cell.lblTitle.highlight(searchedText: rawTitle[indexPath.section][indexPath.row], color: .white)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        view.backgroundColor = .black
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: UIScreen.main.bounds.width-8, height: 50))
        label.textColor = .red
        label.text = sectionHeader[section]
        label.font = R.font.robotoRegular(size: 17) ?? UIFont.systemFont(ofSize: 17)
        view.addSubview(label)
        return view
    }
    
}

extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let manager = EngageSDK.shared else { return }
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.editKey(title: "ProximiPRO API Key", keyValue: userManager.sdkKey, editFor: .apiKey)
            case 1:
                self.editKey(title: "iBeacon UUID", keyValue: userManager.sdkUuidKey, editFor: .uuid)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                manager.isBackgroundMode = !(manager.isBackgroundMode)
            case 1:
                manager.isNotificationEnabled = manager.isBackgroundMode ? !(manager.isNotificationEnabled) : manager.isNotificationEnabled
            default:
                break
            }
            self.tableView.reloadRows(at: [indexPath, IndexPath(row: indexPath.row == 0 ? 1 : 0, section: 1)], with: .automatic)
        case 2:
            switch indexPath.row {
            case 0:
                userManager.autoRefreshContentIsOn = !(userManager.autoRefreshContentIsOn)
            case 1:
                if userManager.autoRefreshContentIsOn {
                    self.showAutoRefreshContent()
                }
            default:
                break
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        case 3:
            switch indexPath.row {
            case 0:
                manager.isLocationBasedContentEnabled = !(manager.isLocationBasedContentEnabled)
            default:
                break
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        case 4:
            switch indexPath.row {
            case 0:
                self.showAutoRefreshContentInMinutes()
            case 1:
                self.showAutoRefreshContentInHours()
            default:
                break
            }
        case 5:
            switch indexPath.row {
            case 0:
                self.showTxPower()
            default:
                break
            }
        default:
            break
        }
    }
    
    func showMessageResetApp() {
        let restartApp = UIAlertAction(title: "Restart", style: .destructive) {
            (alert) -> Void in
            if let navController = R.storyboard.main.restartNavigationController() {
                navController.changeRootViewWithAnimation(success: nil)
            }
        }
        let controller = UIAlertController.showAlert(title: "Restart Required!", message: "In order to apply these recent changes, the app needs to be restqrted.", actions: [restartApp], preferredStyle: .alert, addTextFieldConfigurationHandler: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func editKey(title: String, keyValue: String, editFor: EditKeys) {
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) in
            // Do nothing on cancel
        })
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction)in
            // Ok clicked
            //            guard self.alertTextField.text ?? "" != (editFor == .apiKey ? userManager.sdkKey : userManager.sdkUuidKey) else { return }
            switch editFor {
            case .apiKey:
                guard let manager = EngageSDK.shared else { return }
                manager.callCheckClientKey(apiKey: self.alertTextField.text ?? "") { (response) in
                    DispatchQueue.main.async {
                        if let _ = response {
                            userManager.sdkKey = self.alertTextField.text ?? userManager.sdkKey
                            self.showMessageResetApp()
                        } else {
                            self.showSnakBar(message: "The Provided API key is not valid. Please provide an valid API key.")
                        }
                    }
                }
            case .uuid:
                DispatchQueue.main.async {
                    if let _ = UUID(uuidString: self.alertTextField.text ?? "") {
                        userManager.sdkUuidKey = self.alertTextField.text ?? userManager.sdkUuidKey
                        self.showMessageResetApp()
                    } else {
                        self.showSnakBar(message: "The Provided UUID key is not valid. Please provide an valid UUID key.")
                    }
                }
            }
        })
        let message = "Note: In order to apply this change, app needs to be restarted. Cancel if you don't want to change anything."
        let controller = UIAlertController.showAlert(title: title, message: message, actions: [cancelAction, okAction], preferredStyle: .alert, addTextFieldConfigurationHandler: { textField in
            self.alertTextField = textField
            self.alertTextField.text = keyValue
        })
        self.present(controller, animated: true, completion: nil)
    }
    
}
typealias Handler = ((UIAlertAction) -> Void)?

extension SettingsViewController {
    
    func showAutoRefreshContent() {
        let handler: Handler = { (alert) -> Void in
            if let refreshInterval = AutoRefreshContent(rawValue: alert.title ?? "") {
                userManager.autoRefreshContent = refreshInterval
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        var actions = [UIAlertAction]()
        AutoRefreshContent.allCases.forEach { (content) in
            actions.append(UIAlertAction(title: content.rawValue, style: .default, handler: handler))
        }
        let cancle = UIAlertAction(title: "Cancle", style: .cancel) { (alert) in
            
        }
        actions.append(cancle)
        let controller = UIAlertController.showAlert(title: "Auto Refresh Interval", message: "Select time interval", actions: actions, preferredStyle: .actionSheet, addTextFieldConfigurationHandler: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func showAutoRefreshContentInMinutes() {
        let minutesHandler: Handler = { (alert) -> Void in
            guard let manager = EngageSDK.shared else { return }
            if let refreshInterval = AutoRefreshContentInMinutes(rawValue: alert.title ?? "") {
                DispatchQueue.main.async {
                    manager.snoozeNotificationTimeInMinutes = refreshInterval.value
                    self.tableView.reloadData()
                }
            }
        }
        var actions = [UIAlertAction]()
        AutoRefreshContentInMinutes.allCases.forEach { (content) in
            actions.append(UIAlertAction(title: content.rawValue, style: .default, handler: minutesHandler))
        }
        let cancle = UIAlertAction(title: "Cancle", style: .cancel) { (alert) in
            
        }
        actions.append(cancle)
        let controller = UIAlertController.showAlert(title: "Snooze Notification", message: "Select time snooze notification", actions: actions, preferredStyle: .actionSheet, addTextFieldConfigurationHandler: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func showAutoRefreshContentInHours() {
        let handler: Handler = { (alert) -> Void in
            guard let manager = EngageSDK.shared else { return }
            if let refreshInterval = AutoRefreshContentInHours(rawValue: alert.title ?? "") {
                DispatchQueue.main.async {
                    manager.snoozeContentTimeInHours = refreshInterval.value
                    self.tableView.reloadData()
                }
            }
        }
        var actions = [UIAlertAction]()
        AutoRefreshContentInHours.allCases.forEach { (content) in
            actions.append(UIAlertAction(title: content.rawValue, style: .default, handler: handler))
        }
        let cancle = UIAlertAction(title: "Cancle", style: .cancel) { (alert) in
            
        }
        actions.append(cancle)
        let controller = UIAlertController.showAlert(title: "Snooze Content", message: "Select time snooze content", actions: actions, preferredStyle: .actionSheet, addTextFieldConfigurationHandler: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func showTxPower() {
        let minutesHandler: Handler = { (alert) -> Void in
            guard let manager = EngageSDK.shared else { return }
            if let power = TxPower(rawValue: alert.title ?? "") {
                DispatchQueue.main.async {
                    manager.txPower = power.value
                    self.tableView.reloadData()
                }
            }
        }
        var actions = [UIAlertAction]()
        TxPower.allCases.forEach { (content) in
            actions.append(UIAlertAction(title: content.rawValue, style: .default, handler: minutesHandler))
        }
        let cancle = UIAlertAction(title: "Cancle", style: .cancel) { (alert) in
            
        }
        actions.append(cancle)
        let controller = UIAlertController.showAlert(title: "Beacon Power", message: "Select TxPower for beacon", actions: actions, preferredStyle: .actionSheet, addTextFieldConfigurationHandler: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
}
