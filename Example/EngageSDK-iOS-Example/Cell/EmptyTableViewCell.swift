//
//  EmptyTableViewCell.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 16/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
