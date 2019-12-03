# EngageSDK
Welcome to Engage SDK user guide. Here, you can find all the code snippets and required to use each and every feature of the Engage SDK. You can also view SDK documentation [here](docs/engage/index.html). Let's get started.


## Add Engage in your Project

It's very simple to add engage SDK to your ios project. open your profile file and add the following code into it.

```groovy
pod 'EngageSDK'
```
`Note -> Supports up to xcode 10.3` 
just type pod install in the terminal and all set.
You can find documentation of the SDK [here](docs/engage/index.html). Follow this user guide to get started with the SDK.

## Initialization

The SDK needs to be initialized before one can use it. Please note that in order to use this SDK, it must be initialized before using it, otherwise it will throw `Error`. To initialize this SDK, the following things are required:

* **ProximiPro API Key:** Provided by Engage Platform
* **Client ID:**  Provided by Engage Platform
* **Region Identifier:** [User defined]
* **UUID:** Provided by Engage Platform
* **Project Name/ Application Name:** Used as Notification title for all the notifications displayed from the SDK.



> In order to initialize this SDK for the first time, an internet connection is required as it checks and verifies the API key with the server. SDK cannot be initialized without the internet connection. Once the API key is verified through the internet, it no longer requires an internet connection for subsequent runs/initializations.



```swift
// Create Initialization request
let initializationRequest = InitializationRequest(
  apiKey: "API_KEY", 
  appName: "App_Name", 
  regionId: "REGION_IDENTIFIER", 
  clientId: "CLIENT_ID", 
  uuid: "UUID"
)

// InitializeEngage
let _  =  EngageSDK.init(initData: initializationRequest, 
            onSuccess: {
                // SDK initialized
            }) { (errorMessage) in
                // Error initializing SDK
            }
            
            
```
#### Check if SDK is initialized or not

Once the API key is verified, the SDK will be auto initialized on the app start. No need to reinitialize it every time. Here's how you can check whether the SDK is initialized or not

```
        guard let engage = EngageSDK.shared else { return }
        if engage.isInitialized { /* SDK is initialized */ }
```

## Usage

To use SDK, there is one single entry point for all kinds of operation. The entry point is `Engage` class. This how the singleton instance of the SDK can be retrieved:

```swift
// returns SDK instance if it's initialized, throws nil otherwise
guard let engage = EngageSDK.shared else { return }
```



## Register User

To register the user with the SDK, 2 things are needed:

* **BirthDate** of the user `birthDate: String, with dateFormat = "yyyy/MM/dd"`
* **Gender** of the user `gender:Gender`: 1. `Gender.Male` 2. `Gender.Female`

```swift
    guard let engage = EngageSDK.shared else { return }
    engage.callRegisterUserApi(birthDate: BirthDate, gender: Gender) 
    { (response) in
            if let _ = response {
                // User Registered successfully
            } else {
                // Unable to register User
            }
    }
```



## Tags

Once the user is registered, tags related to the account can be retrieved like this:

#### Get User Default Tags

```swift
  guard let engage = EngageSDK.shared else { return }
  var tags = engage.userInfo?.tags ?? [Tag]()
```



#### Update User BirthDate, Gender and Tags

These tags are selectable so the user can make a selection of his interest. Once the selection is done, it needs to be synced with the server. For that, `callUpdateUserApi` API can be used like this:

```swift
   guard let engage = EngageSDK.shared else { return }
   engage.callUpdateUserApi(birthDate: text, gender: gender, tags: tags) { (response) in
            if let response = response {
                // User Updated successfully
            } else {
                // Unable to update User
            }
    }
```



## Get Updated User Information

Once the user is registered successfully with the SDK, you can retrieve all the user related information from engage config object like this:

```swift
 guard let engage = EngageSDK.shared else { return }
 val birthDate  = engage.userInfo?.birthDate
 val gender     = engage.userInfo?.gender
 val tags       = engage.userInfo?.tags
```
## Starting and Stopping Scan

#### Start Scan

This SDK supports lifecycle aware scans which means that scan results will only be delivered if the is in the foreground. Also, upon scan results, SDK shows notifications based on the rules triggered.

> Note that the SDK uses foreground service for beacon scanning. This service will display a notification whenever the scan is started and will remove the notification whenever the scan is stopped. see [***Configure Service Notification***](#configure-service-notification) section to modify default notification settings.



`engage.start{...}` method call requires Location permission to start scanning as an underlying native module requires this permission for scanning beacons. Make sure that the app has location permission before starting the scan, otherwise the scanning process won't get started and it won't give any scan results.

```swift
            // start scan
            guard let engage = EngageSDK.shared else { return }
// assign location manager object to sdk before start scaning
if engage.locationManager == nil {
    engage.locationManager = locationManager
}
// if user don't allow the location, notifiation and bluetooth start method return with error message
engage.start { (message, permission) in
    // message - error message
    // permission- true/false
    // other wise your scan is started
    engage.onBeaconCamped = { beacon, location in
        // called on beacon detection
    }
    engage.onBeaconExit = { beacon, location in
        // called when beacon exit
    }
    engage.onRangedBeacon = { beacons in
        // List of detected beacons 
    }
    engage.onRuleTriggeres = { rule, location in
        // called when a rule is triggered upon beacon detection
    }
    engage.onLocationRuleTriggeres = { rule, location in
        // called when a rule is triggered upon location detection
    }
    engage.onPermissionChange = { (message, permission) in
        if !permission {
            // if user change any permission then this block called
        }
    }
    engage.locationCheckLiveData = { location in
        if let location = location {
            // Called when a SDK search for the location based content
        }
    }
}
```



#### Stop Scan

Stopping an ongoing scan is pretty easy. It will remove all the background and foreground, scan listeners.

```swift
engage.stop()
```

The service notification has a `Stop Scan` button that stops the ongoing scan process. As this notification is shown as a part of the foreground service, it cannot be canceled until the service is stopped.



## Background Mode

This SDK supports background scan mode to keep scanning even when the app is not in the foreground. It displays notifications on scan results and those notifications lead back to the main app. Settings background mode enabled, it will also start a scan on device boot.

#### Enable Background Mode

```swift
engage.isBackgroundModeEnabled = true
engage.isNotificationEnabled = true
```

> In order to enable background scan, both `isBackground `and `isNotificationEnabled` needs to be set to true. If one of them is not set to true, the background scan won't start.
>
> Note that in order to apply these changes, the scan process doesn't need to be restarted as it is needed for other settings.



## Location-Based Content

Location-based content enables the SDK to use device location and fetch data based on the location. To enabled location-based content:

```swift
engage.isLocationBasedContentEnabled = true
```

## Using ContentListView

The SDK provides a list view to load all the supported content when the app is in the foreground. Using this `ContentListView` is very simple.

Start by adding the view in your UITableViewCell:

Assign ListTableViewCell class to UITableViewCell and connect WKWebView to outlet : `https://ibb.co/Kj4jDsY`

Assign WkWebView to webview  : `https://ibb.co/8gk3jph`

#### Setting content for the view

Once you receive the rule from the `onRuleTriggered` method, you can create instances of the `Content` class and create a list of it. Then all you need to do is pass the content list to the view and it will load data from the server.

```swift
cell.loadContent(data: contents[indexPath.row]) // where contents is [Content]
```

## Using ContentDetailView

As the SDK provides `ContentView` to load the list of content, it also provides a detailed view of the content. Using `ContentView` is pretty simple. Assign `ContentView` class to `UIView`:



#### Loading content in `ContentView`

You can pass the `Content` instance from one component.

```swift
contentView.loadContent(content: content)
```

   

## Handle Notifications

The SDK shows notifications based on the rule triggered once the scanning process is started. These notifications when clicked launches the application by default.

```swift
    // iOS App default methods to get notification 
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationData = notification.request.content.userInfo
        completionHandler([.alert, .sound])
        // Called when notification arrive 
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification Clicked")
        // Called when notification clicked 
    }
```

#### Retrieve Information from the tapped notification

You'll need to pass `userInfo` to the SDK directly to get the content.

```swift
// Before call this method EngageSDK must be initialized.
func handleNotification(userInfo: [AnyHashable: Any]) {
        EngageSDK.shared?.onPromotion = { promostionAction in
            print("On Promotion \(promostionAction)")
            EngageSDK.shared?.callPromotionApi(id: promostionAction.meta?.params?.id ?? "", responseData: { (response) in
              // user will get content here
            })
        }
        EngageSDK.shared?.handleNotification(userInfo: userInfo, isWebContent: {
            // Called when notification contain web content
        })
    }
```

### FCM notification from SDK

Geting notification from FCM you just get the token from firebase and pass to SDK.

```swift
    engage.callPushNotificationRegister(pushToken: "FCM Token", responseData: { (response) in
            // do nothing
        })
```

### Update Beacon UUID & API key

The SDK uses default beacon UUID provided by the ProximiPRO Engage platform. However if any requirement arises to change beacon UUID, it can be done very easily:

> Please make sure that the UUID is in the right format and is not incorrect.  Also, in order for SDK to apply changes, the app needs to be restarted.

The SDK provides a way to change the API key used by the SDK.

> Once the API key is changed, the SDK re-verifies it on the next run to make sure that it is a valid API key. If it fails to verify the new API key then it won't initialize the SDK. Also, for this change to be effective, the app needs to be restarted.

```swift
// returns true if the uuid is updated successfully, false otherwise
 Re-initialized the SDK
```

### Snoozing notification & Content

Engage SDK allows you to snooze untapped notifications and content of the tapped notifications in an easy way.

#### Snooze Untapped Notifications

```swift
engage.snoozeNotificationTimeInMinutes = Minutes
```

#### Snooze Content

```swift
engage.snoozeContentTimeInHours = Hours
```

### TxPower
iOS don't provide TxPower in beacon, for distance calculation SDK provide the option to add TxPower

```swift
engage.txPower = txPower_value : `https://ibb.co/hfG0bQZ`
```

### Logs
To enable the event log SDK provide the log methods 

##### FCM LOG
Push notification log
```swift
    guard let engage = EngageSDK.shared else { return }
    engage.callLogPushNotification(notificationId: notifiaction id "id", action: action like "open" or "click") {  (response) in
        print(response ?? "")
    }
```

#### Event log

In event log you can pass the log type like .details, .fav and .social.
```swift
       guard let engage = EngageSDK.shared else { return }
        engage.callLogEvent(logType: .details, contentId: "contentId", contentType: "contentType", param2: nil, beacon: "current beacon", location: "current location") { (response) in
            if let response = response {
                print(response)
            } else {
                print("fail")
            }
        }
```

### Log out from SDK

Logging out from SDK stops the ongoing scans and resets all the settings to default.

```swift
engage.logout()
```


