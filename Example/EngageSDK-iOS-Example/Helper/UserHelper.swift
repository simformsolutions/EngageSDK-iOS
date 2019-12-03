//
//  UserHelper.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 16/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit

import Foundation
import EngageSDK

private struct AppConstants {
    
    // NSUserDefaults persistence keys
    static let isUserLogin = "isUserLogin"
    static let sdkKey = "sdkKey"
    static let sdkUuidKey = "sdkUuidKey"
    static let fcmToken = "fcmToken"
    static let autoRefreshContent = "autoRefreshContent"
    static let autoRefreshContentIsOn = "autoRefreshContentIsOn"
}

let userManager = UserManager.shared

public class UserManager {
    
    // static properties get lazy evaluation and dispatch_once_t for free
    private struct Static {
        static let instance = UserManager()
    }
    
    // this is the Swift way to do singletons
    class var shared: UserManager {
        return Static.instance
    }
    
    // user authentication always begins with a UUID
    private let userDefaults = UserDefaults.standard
    
    var isUserLogin: Bool {
        get {
            return userDefaults.bool(forKey: AppConstants.isUserLogin)
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: AppConstants.isUserLogin)
            userDefaults.synchronize()
        }
    }
    
    var sdkKey: String {
        get {
            return userDefaults.string(forKey: AppConstants.sdkKey) ?? ""
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: AppConstants.sdkKey)
            userDefaults.synchronize()
        }
    }
    
    var sdkUuidKey: String {
        get {
            return userDefaults.string(forKey: AppConstants.sdkUuidKey) ?? ProximiProApp.sdkUUID
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: AppConstants.sdkUuidKey)
            userDefaults.synchronize()
        }
    }
    
    var fcmToken: String {
        get {
            return userDefaults.string(forKey: AppConstants.fcmToken) ?? ""
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: AppConstants.fcmToken)
            userDefaults.synchronize()
        }
    }
    
    var autoRefreshContent: AutoRefreshContent {
        get {
            return AutoRefreshContent(rawValue: userDefaults.string(forKey: AppConstants.autoRefreshContent) ?? AutoRefreshContent.tenSeconds.rawValue) ?? AutoRefreshContent.tenSeconds
        }
        set (newValue) {
            userDefaults.set(newValue.rawValue, forKey: AppConstants.autoRefreshContent)
            userDefaults.synchronize()
        }
    }
    
    var autoRefreshContentIsOn: Bool {
        get {
            return userDefaults.bool(forKey: AppConstants.autoRefreshContentIsOn)
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: AppConstants.autoRefreshContentIsOn)
            userDefaults.synchronize()
        }
    }
    
}

extension UserManager {
    
    //  MARK:- clearAllData
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }
    
}

extension UserDefaults {
    
    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
}
