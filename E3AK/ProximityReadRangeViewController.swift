//
//  ProximityReadRangeViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import CoreBluetooth

class ProximityReadRangeViewController: BLE_ViewController {

    @IBOutlet weak var deviceDistanceView: UIView!
    @IBOutlet weak var distanceSettingView: UIView!
    @IBOutlet weak var deviceSettingSliderValueLabel: UILabel!
    
    @IBOutlet weak var levelSlider: UISlider!
    @IBOutlet weak var Label_CurrentRSSILevel: UILabel!
    @IBOutlet weak var deviceDistanceTitle: UILabel!
    @IBOutlet weak var proximityReadRangeTitle: UILabel!
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
        
        //Label_CurrentRSSILevel.text = ""//String(format:"%d",Convert_RSSI_to_LEVEL(Int(selectedDevice.rssi!)))
        //
        //selectedDevice.readRSSI()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(my_readRssi), userInfo: nil, repeats: true)
        
        
        deviceSettingSliderValueLabel.text = String(format:"%d",setupRSSILevel)
        
        let defSliderValue = Float(setupRSSILevel) / 100 / 0.2
        
        //  / 0.2)
        levelSlider.setValue(defSliderValue, animated: true)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)

        
    }
    
    @IBAction func deviceSettingSliderValueChanged(_ sender: UISlider) {
        
        var currentValue = Int(sender.value * 100 * 0.2)
        
//        if currentValue <= 1{
//         currentValue = 1
//            levelSlider.setValue(Float(currentValue) / 100 / 0.2
//, animated: true)
//
//        }
        
        
        deviceSettingSliderValueLabel.text = "\(currentValue)"
        saveExpectLevelToDbByUUID(selectedDevice.identifier.uuidString, currentValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func peripheral(_ peripheral: CBPeripheral,
                             didReadRSSI RSSI: NSNumber,
                             error: Error?) {
        let rssi = RSSI.intValue
       
        print("rssi = \(rssi)")
        Label_CurrentRSSILevel.text = String(format:"%d",Convert_RSSI_to_LEVEL(rssi))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //20180309 讀取裝置距離
    @objc func my_readRssi() {
        selectedDevice.readRSSI()
    }

}
