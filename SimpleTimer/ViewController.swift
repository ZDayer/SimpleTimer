//
//  ViewController.swift
//  SimpleTimer
//
//  Created by zhaoyang on 2020/6/12.
//  Copyright © 2020 zhaoyang. All rights reserved.
//

import UIKit
import SimpleTimerKit
let defaultTimeInterval: TimeInterval = 20

class ViewController: UIViewController {

    @IBOutlet weak var lblTimer: UILabel!
    var timer: Timers!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showFinishAlert(_:)), name: NSNotification.Name(rawValue: "taskDidFinishedInWidgetNotification"), object: true)
        
        let userDefault = UserDefaults(suiteName: "group.zdyer.simpleTimer.shareData")
        print("test value = \(String(describing: userDefault?.object(forKey: "testKey")))")
        

    }
    
    private func updateLabel() {
        lblTimer.text = timer.leftTimeString
    }
    
    @objc func showFinishAlert(_ finished: Bool) {
        let ac = UIAlertController(title: nil, message: finished ? "Finished" : "Stopped", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] action in
            ac!.dismiss(animated: true, completion: nil)
        }))
        
        present(ac, animated: true, completion: nil)
                
    }
    
    
    
    @IBAction func btnStartPressed(_ sender: Any) {
        if timer == nil {
            timer = Timers(timeInteral: defaultTimeInterval)
        }
        
        let (started, error) = timer.start(updateTick: { [weak self] leftTick in
            self!.updateLabel()
        }) { [weak self] finished in
            self!.showFinishAlert(finished)
            self!.timer = nil
        }
        if started {
            updateLabel()
        } else {
            if let realError = error {
                print("error: \(realError.code)")
            }
        }

    }
    
    
    
    @IBAction func btnStopPressed(_ sender: Any) {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop()
            if !stopped {
                if let realError = error {
                    print("error: \(realError.code)")
                }
            }
            
        }
    }
    
    
    
    @objc func applicationWillResignActive() {
        if timer == nil {
            clearDefaults()
        } else {
            if timer.running {
                saveDefaults()
            } else {
                clearDefaults()
            }
        }
    }
    
    private func saveDefaults() {
        let userDefault = UserDefaults(suiteName: "group.zdyer.simpleTimer.shareData")
        userDefault?.set(Int(timer.leftTime), forKey: keyLeftTime)
        userDefault?.set(Int(Date().timeIntervalSince1970), forKey: keyQuitDate)
        userDefault?.synchronize()
        
    }
    
    private func clearDefaults() {
        let userDefault = UserDefaults(suiteName: "group.zdyer.simpleTimer.shareData")
        userDefault?.removeObject(forKey: keyLeftTime)
        userDefault?.removeObject(forKey: keyQuitDate)
        userDefault?.synchronize()
    }
    
}
