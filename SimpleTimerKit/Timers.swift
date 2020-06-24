//
//  Timers.swift
//  SimpleTimer
//
//  Created by zhaoyang on 2020/6/12.
//  Copyright © 2020 zhaoyang. All rights reserved.
//

import UIKit

public let keyLeftTime = "com.zdyer.simpleTimer.leftTime"
public let keyQuitDate = "com.zdyer.simpleTimer.quitdate"


let timerErrorDomain = "SimpleTimerError"

public enum SimpleTimerError: Int {
    case AleadyRunning = 1001
    case NegativeLeftTime = 1002
    case NotRunning = 1003
}


extension TimeInterval {
    func toString() -> String {
        let totalSecond = Int(self)
        let minute = totalSecond / 60
        let second = totalSecond % 60
        switch (minute, second) {
        case (0...9, 0...9):
            return "0\(minute):0\(second)"
        case (0...9, _):
            return "0\(minute):\(second)"
        case (_, 0...9):
            return "\(minute):0\(second)"
        default:
            return "\(minute):\(second)"
        }
        
    }
}


public class Timers: NSObject {
    
    public var running = false
    
    public var leftTime: TimeInterval {
        didSet {
            if leftTime < 0 {
                leftTime = 0
            }
        }
    }
    
    public var leftTimeString: String {
        get {
            return leftTime.toString()
        }
    }
    
    private var timerTickHandler: ((TimeInterval) -> ())? = nil
    private var timerStopHandler: ((Bool) -> ())? = nil
    private var timer: Timer!

    public init(timeInteral: TimeInterval) {
        leftTime = timeInteral
    }
    
    public func start(updateTick: ((TimeInterval) -> Void)?, stopHandler: ((Bool) -> Void)?) -> (start: Bool, error: NSError?) {
        if running {
            return (false, NSError(domain: timerErrorDomain, code: SimpleTimerError.AleadyRunning.rawValue, userInfo: nil))
        }
        
        if leftTime < 0 {
            return (false, NSError(domain: timerErrorDomain, code: SimpleTimerError.NegativeLeftTime.rawValue, userInfo: nil))
        }
        
        timerTickHandler = updateTick
        timerStopHandler = stopHandler
        
        running = true
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTick), userInfo: nil, repeats: true)
        
        return (true, nil)
    }

    public func stop() -> (stopped: Bool, error: NSError?) {
        if !running {
            return (false, NSError(domain: timerErrorDomain, code: SimpleTimerError.NotRunning.rawValue, userInfo: nil))
        }
        running = false
        timer.invalidate()
        timer = nil
        
        if let stopHandler = timerStopHandler {
            stopHandler(leftTime <= 0)
        }
        
        timerStopHandler = nil
        timerTickHandler = nil
        return (true, nil)
    }
    
    
    @objc private func countTick() {
        leftTime -= 1
        if let tickHandler = timerTickHandler {
            tickHandler(leftTime)
        }
        if leftTime <= 0 {
            _ = stop()
        }
    }
}
