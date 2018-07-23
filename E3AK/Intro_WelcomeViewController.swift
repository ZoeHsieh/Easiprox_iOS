//
//  Intro_WelcomeViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/7.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import Foundation
import ChameleonFramework
import CoreBluetooth

enum SearchStatus {
    case Searching
    case Finished
}



class Intro_WelcomeViewController: BLE_ViewController {

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchingView: UIView!
    @IBOutlet weak var findDeviceView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var searchingLabel: UILabel!
    @IBOutlet weak var searchResultLabel: UILabel!
    @IBOutlet weak var pleasePressNextLabel: UILabel!
    var deviceInfoList: [DeviceInfo] = [];
    var selectDeviceIndex:Int = 0
    var searchStatus: SearchStatus = .Searching
    
    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeLabel.text = self.GetSimpleLocalizedString("Welcome")
        searchingLabel.text = self.GetSimpleLocalizedString("Searching")
        searchResultLabel.text = self.GetSimpleLocalizedString("Search result")
        pleasePressNextLabel.text = self.GetSimpleLocalizedString("Please press Next to continue")
        nextButton.setTitle(self.GetSimpleLocalizedString("Next"), for: .normal)
        rightButton.setTitle(self.GetSimpleLocalizedString("Skip"), for: .normal)
        loadingImageView.rotate360Degree()
        rightButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
        gradientView.gradientBackground(percent: 160/667)
        nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChooseDevice))
        deviceNameLabel.addGestureRecognizer(gestureRecognizer)
         Config.bleManager.Init(delegate: self)
       
        let when = DispatchTime.now() + 5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
              self.changeRightButtonStatus()
        }
        
    }
    
    public override func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if ( central.state == .poweredOn ) {
           Config.bleManager.ScanBLE()
        } else if ( central.state == .poweredOff ) {
            
            //Open BlueTooth Setting
            openBlueTooth_Setting();
        }

        
    }
    public override func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let rawData = advertisementData["kCBAdvDataManufacturerData"] as? Data
            
            else{
                return
        }
        
        if rawData.count > 0{
            let len:Int = (rawData.count)
            for i in 0 ... len - 1 {
                print(String(format:"raw[%d]=%02x\r\n",i,rawData[i]))
            }
            
        }
        //To check legal device by custom ID.
        let deviceModel:UInt16 = (UInt16(rawData[2]) << 8) | UInt16(rawData[3] & 0x00FF)
        let deviceCategory:UInt8 = rawData[4]
        let customID:UInt16 = (UInt16(rawData[5]) << 8) | UInt16(rawData[6] & 0x00FF)
        let devicerReserved:UInt8 = rawData[7]
        
        //print("customID =\(AdvertisingData.CUSTOM_IDs[customID]!)\r\n")
        //print("customID APP=\(Config.CustomID)\r\n")
        guard let customStr = AdvertisingData.CUSTOM_IDs[customID]
            else{
                return
        }
        
        guard let deviceModelStr = AdvertisingData.dev_Model[deviceModel]
            else{
                return
        }
        if !deviceModelStr.contains(Config.deviceSeries){
            return
            
        }
        
//        guard let deviceColorStr = AdvertisingData.dev_Color[deviceColor] as? String
//            else{
//                return
//        }
        
        guard let deviceCategoryStr = AdvertisingData.dev_Category[deviceCategory]
            else{
                return
        }
        
        
        if Config.CustomID !=  customStr{
            
            return
        }
        let name: String = advertisementData["kCBAdvDataLocalName"] as! String
        let uuid: UUID = peripheral.identifier
        
        let expect_level: Int = readExpectLevelFromDbByUUID(uuid.uuidString);
        
        //print("expect_level = \(expect_level)")
        
        if((RSSI.intValue <= 0) && (RSSI.intValue >= Config.BLE_RSSI_MIN)) {
            
         var tmp: DeviceInfo = DeviceInfo(UUID: uuid, name: name, peripheral: peripheral, model: deviceModelStr, customID: customStr, Category: deviceCategoryStr, reserved: devicerReserved, rssi: RSSI.intValue, current_level: Convert_RSSI_to_LEVEL(RSSI.intValue), expect_level: 0, alive: 3)
            
            if( deviceInfoList.contains(tmp)) {
                
                let du_idx:Int = deviceInfoList.index(of: tmp)!
                
                //print("UUID Dulicate!! Index = \(du_idx)")
                
                //AVG RSSI
                let avg_rssi: Int = (RSSI.intValue + deviceInfoList[du_idx].rssi) / 2;
                tmp.rssi = avg_rssi;
                tmp.current_level = Convert_RSSI_to_LEVEL(avg_rssi)
                
                //print("RSSI: \(RSSI.intValue), LEVEL: \(tmp.current_level)")
                
                deviceInfoList[du_idx] = tmp;
            }
            else {
                deviceInfoList.append(tmp)
                
                //Save to DB
                saveExpectLevelToDbByUUID(uuid.uuidString, expect_level)
            }
        }
        
        
        deviceInfoList.sort();
        

    }
    
    func didTapChooseDevice() {
        var deviceList:[String] = []
        if deviceInfoList.count > 0 {
        for i in 0 ... deviceInfoList.count - 1{
            
         deviceList.append(deviceInfoList[i].name)
        }
        
        UIAlertController.showActionSheet(
            in: self,
            withTitle: self.GetSimpleLocalizedString("Please Choose"),
            message: nil,
            cancelButtonTitle: self.GetSimpleLocalizedString("Cancel"),
            destructiveButtonTitle: nil,
            otherButtonTitles: deviceList, popoverPresentationControllerBlock: nil) { (controller, action, buttonIndex) in
                
                if (buttonIndex == controller.cancelButtonIndex)
                {
                    print("Cancel Tapped")
                }
                else if (buttonIndex == controller.destructiveButtonIndex)
                {
                    print("Delete Tapped")
                }
                else if (buttonIndex >= controller.firstOtherButtonIndex)
                {
                    print("Other Button Index \(buttonIndex - controller.firstOtherButtonIndex)")
                    if self.deviceInfoList.count > 0{
                       self.deviceNameLabel.text = self.deviceInfoList[buttonIndex - controller.firstOtherButtonIndex].name
                        self.selectDeviceIndex = (buttonIndex - controller.firstOtherButtonIndex)
                       }
                    
                  }
               
            }
        }
    }
    
    func changeRightButtonStatus() {
        
        switch searchStatus
        {
        case .Searching: // Scan time out
        
            rightButton.removeTarget(nil, action: nil, for: .allEvents)
            rightButton.addTarget(self, action: #selector(didTapReloadItem), for: .touchUpInside)
            rightButton.setTitle("", for: .normal)
            rightButton.setImage(R.image.researchGreen(), for: .normal)
            
            loadingImageView.stopRotate()
            searchingView.isHidden = true
            findDeviceView.isHidden = false
            
            searchStatus = .Finished
            nextButton.isUserInteractionEnabled = true
            nextButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
            nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            Config.bleManager.ScanBLEStop()
             pleasePressNextLabel.text = self.GetSimpleLocalizedString("Please press Next to continue")
            if deviceInfoList.count == 0{

                deviceNameLabel.text = "  "
                pleasePressNextLabel.text = GetSimpleLocalizedString("Can't find device")
                
                nextButton.isUserInteractionEnabled = false
                nextButton.setBackgroundImage(R.image.btnGray(), for: .normal)
                nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
                
            }else{
                deviceNameLabel.text =  deviceInfoList[0].name
            }
        case .Finished:// start BLE scan
            
            rightButton.removeTarget(nil, action: nil, for: .allEvents)
            rightButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
            rightButton.setTitle(GetSimpleLocalizedString("Skip"), for: .normal)
            rightButton.setImage(nil, for: .normal)
            
            loadingImageView.rotate360Degree()
            searchingView.isHidden = false
            findDeviceView.isHidden = true
            
            searchStatus = .Searching
            nextButton.isUserInteractionEnabled = false
            nextButton.setBackgroundImage(R.image.btnGray(), for: .normal)
            nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
              Config.bleManager.ScanBLE()
        }
    }
    
    func didTapReloadItem() {
        
        changeRightButtonStatus()
        let when = DispatchTime.now() + 10
            
        // change 2 to desired number of seconds
      
        DispatchQueue.main.asyncAfter(deadline: when){
            
            self.changeRightButtonStatus()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("test2")
        if (segue.identifier == "intro_Pass") {
            let nvc = segue.destination  as! Intro_PasswordViewController
            
            ///let vc = nvc.topViewController as! Intro_PasswordViewController
             nvc.selectedDevice = deviceInfoList[selectDeviceIndex].peripheral
            print( "device name= \(nvc.selectedDevice.name)")
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        /*if(identifier == "enroll") {
            if(isAutoMode) {
                //print("Need Disable 'AUTO-MODE' First!!")
                showAlert(message: GetSimpleLocalizedString("k_ALERT_DETAIL"));
                
                return false;
            }
            else {
                return true
            }
        }*/
        
        return true
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
