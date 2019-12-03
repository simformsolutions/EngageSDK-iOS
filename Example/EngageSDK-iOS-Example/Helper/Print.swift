//
//  Print.swift
//  Vix-App
//
//  Created by Ketan Chopda on 10/06/19.
//  Copyright © 2019 Sinform Solutions. All rights reserved.
//

import Foundation

func print(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(item(), separator: separator, terminator: terminator)
    #endif
}
