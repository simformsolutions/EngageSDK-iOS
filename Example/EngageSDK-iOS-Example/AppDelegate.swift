//
//  AppDelegate.swift
//  EngageSDK
//
//  Created by ProximiPRO on 13/08/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import UserNotifications
import EngageSDK
import Bagel
import Firebase
import Messages

public typealias Success = () -> Void

enum NotificationApi: String {
    case campaign = "notification_id"
    case url = "url"
    case title = "title"
    case message = "message"
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var isFromNotification: Bool = false
    var deviceToken: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Bagel.start()
        FirebaseApp.configure()
        DispatchQueue.delay(bySeconds: 1) {
            if !(self.isFromNotification) {
                self.switchToHomeScreen(success: nil)
            }
        }
        // removing observer for fcm token refresh
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        // adding observer for fcm token refresh
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        self.setUpNavigationBarAppearance()
        return true
    }
    
    /// Setup navigation bar appearance
    private func setUpNavigationBarAppearance() {
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().backgroundColor = .black
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barStyle = .blackOpaque
        UITextField.appearance().keyboardAppearance = .dark
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEVICE TOKEN = \(deviceToken)")
        print(deviceToken.reduce("", {
            $0 + String(format: "%02X", $1)
        }))
        #if DEBUG
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
        #else
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)
        #endif
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification arrive")
        let notificationData = notification.request.content.userInfo
        if let _ = notificationData[NotificationApi.campaign.rawValue] {
            self.handleForGroundNotification(userInfo: notificationData)
        }
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification Clicked")
        guard userManager.isUserLogin else { return }
        self.isFromNotification = true
        let userInfo = response.notification.request.content.userInfo
        let initializationRequest = InitializationRequest(apiKey: userManager.sdkKey, appName: "EngageSDK", regionId: "com.proximipro.engageexampleapp", clientId: "16", uuid: userManager.sdkUuidKey)
        if userInfo.count > 0 {
            if let _ = EngageSDK.shared {
                if let id = userInfo[NotificationApi.campaign.rawValue] as? String {
                    self.callPushLogAPI(id: id)
                    self.handlefcmBackgroundNotification(userInfo: userInfo)
                } else {
                    self.handleNotification(userInfo: userInfo)
                }
            } else {
                let _  =  EngageSDK.init(initData: initializationRequest, onSuccess: {
                    if let navController = self.window?.rootViewController as? UINavigationController {
                        navController.popToRootViewController(animated: true)
                    }
                    if let id = userInfo[NotificationApi.campaign.rawValue] as? String {
                        self.callPushLogAPI(id: id)
                        self.handlefcmBackgroundNotification(userInfo: userInfo)
                    } else {
                        self.handleNotification(userInfo: userInfo)
                    }
                }) { (errorMessage) in
                    self.switchToHomeScreen(success: nil)
                }
            }
        }
        completionHandler()
    }
    
    func handleForGroundNotification(userInfo: [AnyHashable: Any]) {
        if let navigationController = self.window?.rootViewController as? UINavigationController, let homeScreen = navigationController.visibleViewController as? HomeViewController {
            homeScreen.notificationAlert(userData: userInfo)
        }
    }
    
    func checkForHomeScreen() -> Bool {
        if let navigationController = self.window?.rootViewController as? UINavigationController, navigationController.viewControllers.first is HomeViewController {
            navigationController.popToRootViewController(animated: true)
            return true
        }
        return false
    }
    
    func handlefcmBackgroundNotification(userInfo: [AnyHashable: Any]) {
        DispatchQueue.main.async {
            if let navController = self.window?.rootViewController as? UINavigationController {
                if navController.viewControllers[0] is SplashScreenViewController {
                    self.switchToHomeScreen {
                        if let navigationController = self.window?.rootViewController as? UINavigationController, let homeScreen = navigationController.visibleViewController as? HomeViewController, let url = userInfo[NotificationApi.url.rawValue] as? String {
                            homeScreen.callNotificationContent(url: url)
                        }
                    }
                } else {
                    navController.popToRootViewController(animated: true)
                    if let navigationController = self.window?.rootViewController as? UINavigationController, let homeScreen = navigationController.visibleViewController as? HomeViewController, let url = userInfo[NotificationApi.url.rawValue] as? String {
                        homeScreen.callNotificationContent(url: url)
                    }
                }
            }
        }
        
    }
    
    func callPushLogAPI(id: String) {
        guard let manager = EngageSDK.shared else { return }
        manager.callLogPushNotification(notificationId: id, action: "open") { (response) in
            print(response ?? "")
        }
    }
    
    func handleNotification(userInfo: [AnyHashable: Any]) {
        EngageSDK.shared?.onPromotion = { promostionAction in
            print("On Promotion \(promostionAction)")
            EngageSDK.shared?.callPromotionApi(id: promostionAction.meta?.params?.id ?? "", responseData: { (response) in
                DispatchQueue.main.async {
                    if let navController = self.window?.rootViewController as? UINavigationController {
                        if navController.viewControllers[0] is SplashScreenViewController {
                            self.switchToHomeScreen {
                                self.parseResponse(responseData: response)
                            }
                        } else {
                            navController.popToRootViewController(animated: true)
                            self.parseResponse(responseData: response)
                        }
                    }
                }
            })
        }
        EngageSDK.shared?.handleNotification(userInfo: userInfo, isWebContent: {
            if let navController = self.window?.rootViewController as? UINavigationController {
                if navController.viewControllers[0] is SplashScreenViewController, userManager.isUserLogin {
                    self.switchToHomeScreen(success: nil)
                }
            }
        })
    }
    
    func parseResponse(responseData: ResponseFetchForgroundContent?) {
        if let response = responseData {
            if let detailVC = R.storyboard.main.detailViewController(), let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = appDelegate.window?.rootViewController as? UINavigationController {
                detailVC.content = response
                rootViewController.popToRootViewController(animated: true)
                rootViewController.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    func switchToHomeScreen(success: Success?) {
        DispatchQueue.delay(bySeconds: 1) {
            if userManager.isUserLogin, let homeNav = R.storyboard.main.homeNav() {
                homeNav.changeRootViewWithAnimation(success: success)
            } else if let welcomeNav = R.storyboard.main.loginNav() {
                welcomeNav.changeRootViewWithAnimation(success: success)
            }
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.scheduleLocalNotification(title: "FCM")
        completionHandler(.newData)
    }
    
    // MARK: - FCM Integration
    func setUpForNotificationsWithFirebase(success: @escaping (Bool) -> Void) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                userManager.fcmToken = result.token
                DispatchQueue.main.async {
                    guard let manager = EngageSDK.shared else { return }
                    if !userManager.fcmToken.isEmpty {
                        manager.callPushNotificationRegister(pushToken: userManager.fcmToken, responseData: { (response) in
                            // do nothing
                        })
                    }
                }
                success(true)
            }
        }
    }
    
    @objc func tokenRefreshNotification(_ notification: NSNotification) {
        self.setUpForNotificationsWithFirebase { (success) in
            print("tokenRefreshNotification token refresh")
        }
    }
    
}

// MARK: - Firebase Messaging Delegate Methods
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        userManager.fcmToken = fcmToken
    }
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
}

// MARK:- Notification Helper
extension AppDelegate {
    
    func registerLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func scheduleLocalNotification(title: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.fireNotification(title: title)
            }
        }
    }
    
    func fireNotification(title: String) {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = title
        notificationContent.body = "FCM Test"
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
}


