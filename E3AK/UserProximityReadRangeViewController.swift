//
//  UserProximityReadRangeViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/7/11.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
//
//  ProximityReadRangeViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/12.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

import CoreBluetooth

class UserProximityReadRangeViewController: UIViewController {
    
    @IBOutlet weak var deviceNameView: UIView!
    @IBOutlet weak var deviceDistanceView: UIView!
    @IBOutlet weak var distanceSettingView: UIView!
    
    @IBOutlet weak var deviceModelView: UIView!
    
    @IBOutlet weak var deviceSettingSliderValueLabel: UILabel!
    @IBOutlet weak var deviceDistanceTitle: UILabel!
    @IBOutlet weak var proximityReadRangeTitle: UILabel!
    @IBOutlet weak var deviceModelTitle: UILabel!
    
    @IBOutlet weak var deviceModelValue: UILabel!
    @IBOutlet weak var deviceNameTitle: UILabel!
    
    @IBOutlet weak var Label_CurrentRSSILevel: UILabel!
    
    
    @IBOutlet weak var label_DeviceName: UILabel!
    
    @IBOutlet weak var levelSlider: UISlider!
    
    
     var selectedDevice:CBPeripheral!
    var current_level_RSSI:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = GetSimpleLocalizedString("Proximity Read Range")
        deviceDistanceTitle.text = GetSimpleLocalizedString("Device Distance")
        proximityReadRangeTitle.text = GetSimpleLocalizedString("Proximity Read Range Settings")
      
     
        deviceDistanceView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        distanceSettingView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        
       
        let setupRSSILevel = readExpectLevelFromDbByUUID(selectedDevice.identifier.uuidString)
        
        Label_CurrentRSSILevel.text = String(format:"%d",current_level_RSSI)
        
        deviceSettingSliderValueLabel.text = String(format:"%d",setupRSSILevel)
       
        let defSliderValue = Float(setupRSSILevel) / 100 / 0.2
        
      //  / 0.2)
        levelSlider.setValue(defSliderValue, animated: true)
        
        
    }
    
    @IBAction func deviceSettingSliderValueChanged(_ sender: UISlider) {
        
        let currentValue = Int(sender.value * 100 * 0.2)
        deviceSettingSliderValueLabel.text = "\(currentValue)"
        
        saveExpectLevelToDbByUUID(selectedDevice.identifier.uuidString, currentValue)
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
