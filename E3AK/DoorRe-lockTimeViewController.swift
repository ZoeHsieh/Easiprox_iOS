//
//  DoorRe-lockTimeViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework
import IQKeyboardManagerSwift

class DoorRe_lockTimeViewController: BLE_ViewController {
    
    @IBOutlet weak var secondsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsTableViewController.settingStatus = settingStatesCase.config_device.rawValue
        title = "延遲上鎖時間"
        IQKeyboardManager.shared.enableAutoToolbar = false
        secondsTextField.layer.borderColor = HexColor("c8c7cc")?.cgColor
        secondsTextField.layer.borderWidth = 1.0
        secondsTextField.becomeFirstResponder()
        secondsTextField.setTextFieldPaddingView()
            }

    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
