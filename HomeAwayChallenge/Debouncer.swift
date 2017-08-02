//
//  Debouncer.swift
//  HomeAwayChallenge
//
//  Created by RICHARD TACKETT on 8/1/17.
//  Copyright © 2017 RICHARD TACKETT. All rights reserved.
//

import Foundation

final class Debouncer {
    var callback: (() -> Void)?
    private let interval: TimeInterval
    private var timer: Timer?
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func call() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: false)
    }
    
    @objc private func handleTimer(_ timer: Timer) {
        callback?()
        callback = nil
    }
}
