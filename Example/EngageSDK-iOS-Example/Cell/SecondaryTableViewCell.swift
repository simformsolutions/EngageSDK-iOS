//
//  SecondryTableViewCell.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 17/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit

class SecondaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
