//
//  Intro_DistanceSettingsViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/9.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreBluetooth

class Intro_DistanceSettingsViewController: BLE_ViewController {

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var deviceDistanceView: UIView!
    @IBOutlet weak var distanceSettingView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var deviceSettingSliderValueLabel: UILabel!
    @IBOutlet weak var proximityReadRangeLabel: UILabel!
    @IBOutlet weak var settingProximityReadRangeLabel: UILabel!
    @IBOutlet weak var deviceDistanceLabel: UILabel!
    
    @IBOutlet weak var levelSlider: UISlider!
    @IBOutlet weak var deviceNameTitle: UILabel!
    
    @IBOutlet weak var currentDeviceLevel: UILabel!
    
    var selectedDevice:CBPeripheral!
    var rssiCurrentLevel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceNameTitle.text = selectedDevice.name
        rightButton.setTitle(self.GetSimpleLocalizedString("Skip"), for: .normal)
        deviceDistanceLabel.text = self.GetSimpleLocalizedString("Device Distance")
        proximityReadRangeLabel.text = self.GetSimpleLocalizedString("Proximity Read Range Settings")
        settingProximityReadRangeLabel.text = self.GetSimpleLocalizedString("Please Setting Proximity Read Range")
        nextButton.setTitle(self.GetSimpleLocalizedString("Finish Done"), for: .normal)
        
        
        rightButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
        nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        deviceDistanceView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        distanceSettingView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
       
        let setupRSSILevel = readExpectLevelFromDbByUUID(selectedDevice.identifier.uuidString)
        
        
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
