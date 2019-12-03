//
//  PopUpViewController.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 16/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit
import EngageSDK

class PopUpViewController: UIViewController {

    let titles = ["Major", "Minor", "Event", "RSSI", "Tx Power", "Distance", "Beacon UUID"]

    var beacon: FilterBeacon?
    var event: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnCloseCliked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PopUpViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.popupCollectionViewCell, for: indexPath) else { return UICollectionViewCell() }
        var subTitle = ""
        if let beacon = beacon {
            switch indexPath.row {
            case 0:
                subTitle = beacon.beacon.major.stringValue
            case 1:
                subTitle = beacon.beacon.minor.stringValue
            case 2:
                subTitle = event
            case 3:
                subTitle = Int(beacon.rssi).description
            case 4:
                subTitle = EngageSDK.shared?.txPower.description ?? "0"
            case 5:
                subTitle = beacon.distance.description + " meters"
            default:
                subTitle = beacon.beacon.proximityUUID.uuidString
            }
        }
        cell.setData(title: titles[indexPath.row], subTitle: subTitle)
        return cell
    }
    
}

extension PopUpViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0, 1, 2, 3, 4, 5:
            return CGSize(width: ((UIScreen.main.bounds.width - 12)/2), height: 50)
        default:
            return CGSize(width: (UIScreen.main.bounds.width - 12), height: 50)
        }
    }
    
}
