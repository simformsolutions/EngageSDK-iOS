//
//  PopupCollectionViewCell.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 16/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit

class PopupCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblsubTitle: UILabel!
    
    func setData(title: String, subTitle: String) {
        self.lblTitle.text = title
        self.lblsubTitle.text = subTitle
    }
    
}
