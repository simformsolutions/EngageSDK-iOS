//
//  SearchThrottler.swift
//  Iceburg
//
//  Created by ProximiPRO on 14/06/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import UIKit
import Foundation



public class Throttler {
    
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    private var job: DispatchWorkItem = DispatchWorkItem(block: {})
    private var maxInterval: Double
    
    init(seconds: Double) {
        self.maxInterval = seconds
    }
    
    func throttler(success: @escaping () -> Void) {
        job.cancel()
        job = DispatchWorkItem() {
            success()
        }
        queue.asyncAfter(deadline: .now() + maxInterval, execute: job)
        job.notify(queue: .main) {
        }
    }
    
}
