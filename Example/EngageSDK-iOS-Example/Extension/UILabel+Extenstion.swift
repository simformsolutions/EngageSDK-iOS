//
//  UILabel+Extension.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 17/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import UIKit

extension UILabel {
    
    func highlight(searchedText: String?, color: UIColor = .white, font: UIFont = R.font.robotoBold(size: 17) ?? UIFont.boldSystemFont(ofSize: 17)) {
        guard let txtLabel = self.text, let searchedText = searchedText else {
            return
        }
        let attributeTxt = NSMutableAttributedString(string: txtLabel)
        let range: NSRange = attributeTxt.mutableString.range(of: searchedText, options: .caseInsensitive)
        attributeTxt.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributeTxt.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        self.attributedText = attributeTxt
    }

}
