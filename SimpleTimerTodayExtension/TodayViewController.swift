//
//  TodayViewController.swift
//  SimpleTimerTodayExtension
//
//  Created by zhaoyang on 2020/6/12.
//  Copyright © 2020 zhaoyang. All rights reserved.
//

import UIKit
import NotificationCenter
import SimpleTimerKit
class TodayViewController: UIViewController, NCWidgetProviding {
        
    
    @IBOutlet weak var lblTimer: UILabel!
    var timer: Timers!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lblTimer.text = "Hello, my friend!"
        let userDefault = UserDefaults(suiteName: "group.zdyer.simpleTimer.shareData")
        let leftTimeWhenQuit = userDefault?.integer(forKey: keyLeftTime)
        let quitDate = userDefault?.integer(forKey: keyQuitDate)
        userDefault?.setValue("test value", forKey: "testKey")
        userDefault?.synchronize()
        
        if let leftTimeWhenQuitt = leftTimeWhenQuit, let quitdate = quitDate {
            let passedTimeFromQuit = Date().timeIntervalSince(Date(timeIntervalSince1970: TimeInterval(quitdate)))
            let leftTime = leftTimeWhenQuitt - Int(passedTimeFromQuit)
            
            if leftTime > 0 {
                timer = Timers(timeInteral: TimeInterval(leftTime))
                _ = timer.start(updateTick: { [weak self] leftTick in
                    self!.updateLabel()
                    }, stopHandler: { [weak self] finished in
                        self!.showOpenAppButton()
                })
            } else {
                showOpenAppButton()
            }
        }
    }
    
    
    private func updateLabel() {
        lblTimer.text = timer.leftTimeString
    }
    
    private func showOpenAppButton() {
        lblTimer.text = "Finished"
        preferredContentSize = CGSize(width: 0, height: 100)
        
        let button = UIButton(frame: CGRect(x: 150, y: 50, width: 50, height: 63))
        button.setTitle("Open", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc private func buttonPressed() {
        
        extensionContext?.open(URL(string: "simpleTimer://finised")!, completionHandler: nil)
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
