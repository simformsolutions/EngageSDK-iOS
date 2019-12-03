//
//  DetailViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 18/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import WebKit
import EngageSDK
import CoreLocation

enum IsFrom {
    case homeScreen
    case notification
}

class DetailViewController: UIViewController {
    
    @IBOutlet weak var btnTitle: UILabel!
    @IBOutlet weak var loadContentView: ContentView!
    
    var content: ResponseFetchForgroundContent?
    var beacon: FilterBeacon?
    var location: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnTitle.text = content?.title
        if let content = self.content {
            self.loadContentView.loadContent(content: content)
            guard let manager = EngageSDK.shared else { return }
            manager.callLogEvent(logType: .details, contentId: content.id ?? "", contentType: content.type ?? "", param2: nil, beacon: beacon, location: location) { (response) in
                if let response = response {
                    print(response)
                } else {
                    print("fail")
                }
            }
        }

    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
