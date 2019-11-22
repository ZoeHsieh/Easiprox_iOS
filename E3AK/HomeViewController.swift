//
//  HomeViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/7.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreBluetooth
import UIAlertController_Blocks
import CoreMotion

enum DeviceSearchingStatus {
    case DeviceSearching
    case DeviceNotFound
    case DeviceFound
}


class HomeViewController: BLE_ViewController{

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var doorCheckButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceTypeLabel: UILabel!
    @IBOutlet weak var doorButton: UIButton!
    @IBOutlet weak var openDoorButton: UIButton!
    @IBOutlet weak var doorStatusLabel: UILabel!
    @IBOutlet weak var dotImageView: UIImageView!
    @IBOutlet weak var loadingImageView: UIImageView!
    
    @IBOutlet weak var enrollButon: UIButton!
    
    @IBOutlet weak var infoOperation: UIImageView!    //綠色圈圈0316
    @IBOutlet weak var auto_range_setting: UILabel!   //新增的文字0316
    
    var doorIsOpen = false
    var isAutoMode = false
    var deviceFoundStatus: DeviceSearchingStatus = .DeviceFound
    var deviceInfoList: [DeviceInfo] = [];
    var selectDeviceIndex:Int = 0
    var isAdminEnroll:Bool = false
    var isEnroll:Bool = false
    var isOpenDoor:Bool = false
    var isKeepOpen:Bool = false
    var userEnrollData: Data!
    var adminEnrollData: Data!
    var disTimer:Timer? = nil
    let motionManager = CMMotionManager()
    var shakeTime = 0
     var bgAutoTimer = Timer()
    var scanningTimer = Timer();
    var connectTimer:Timer? = nil

    var isBackground = false
    
    var bgTaskID: UIBackgroundTaskIdentifier?
    var backCount = 0
    
    var backgroundTimers: [Timer] = []
    var isForce:Bool = false
    var ScanningTimerflag = false
    var bgAutoTimerFlag = false
    var isMotion = false
    var isConnected = false
    var selectSetDevice:DeviceInfo?
    var forceDevice:DeviceInfo!
    
    @IBAction func didEnroll(_ sender: Any) {
        if !isAutoMode {
         //StopScanningTimer()
        if deviceInfoList.count > 0 {
            let target = GetTargetDevice()
        self.loginAlert(title:self.GetSimpleLocalizedString("enroll_dialog_title") , subTitle: "", placeHolder1: self.GetSimpleLocalizedString("Please Provide Up to 16 characters"), placeHolder2: self.GetSimpleLocalizedString("4~8 digits"), keyboard1: .default, keyboard2: .numberPad, handler: { (input1, input2) in
            
           // print("user input2: \(input1) & \(input2)")
           
            if !input1!.isEmpty {
                self.isEnroll = true
               // print(input1);
                let userID:[UInt8] = Util.StringtoUINT8ForID(data: input1!, len: BPprotocol.userID_maxLen, fillData: BPprotocol.nullData)
                let userPWD:[UInt8] = Util.StringtoUINT8(data: input2!, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
                
                if input1! == Config.AdminID_ENROLL{
                    //print("admin enroll");
                    
                    let AdminID:[UInt8] = Util.StringtoUINT8(data: Config.AdminID, len: BPprotocol.userID_maxLen, fillData: BPprotocol.nullData)
                    self.adminEnrollData = Config.bpProtocol.setAdminEnroll(UserID: AdminID,Password: userPWD)
                    self.isAdminEnroll = true
                    
                }
                else{
                    self.userEnrollData = Config.bpProtocol.setUserEnroll(UserID: userID, Password: userPWD)
                    //print("user enroll");
                }
               self.start_anima()  //0316
                Config.bleManager.connect(bleDevice: target.peripheral)
                self.StartConnectTimer()
            }
            
        })
        }else{
            StartScanningTimer()
            //showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
            }
            
        }else{
          
          showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       settingsButton.setTitle(GetSimpleLocalizedString("Settings"),for: .normal)
        doorCheckButton.setTitle("  " + GetSimpleLocalizedString("Auto"),for: .normal)
        enrollButon.setTitle(GetSimpleLocalizedString("Enroll"), for: .normal)
        
        gradientView.gradientBackground(percent: 250/667)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChooseDevice))
        deviceNameLabel.addGestureRecognizer(gestureRecognizer)
        openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
        openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        settingsButton.adjustButtonEdgeInsets()
        enrollButon.adjustButtonEdgeInsets()
         Config.bleManager.Init(delegate: self)
        
        deviceFoundStatus = .DeviceNotFound
        changeViewContentSettings()
        deviceNameLabel.text = ""
        deviceTypeLabel.text = ""
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        deviceFoundStatus = .DeviceSearching
        changeViewContentSettings()
        
        //Config.bleManager.ScanBLE()
        StartScanningTimer()
        
        /*if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                if let acc = data?.userAcceleration.z{
                    if self.isAutoMode {
                    if acc > 0{
                       Config.bleManager.ScanBLE()
                    }else{
                      Config.bleManager.ScanBLEStop()
                        }
                    }
                    if acc > 0.5{
                        self.shakeTime += 1
                        print("ShakeTIme: \(self.shakeTime)")
                        
                        self.delayOnMainQueue(delay: 1, closure: {
                            self.shakeTime = 0
                        })
                        
                        if self.isAutoMode {
                        
                            if !self.isOpenDoor {
                            print("open door in auto mode")
                            //self.isMotion  =  true
                            
                            self.StartBgAutoTimer()
                            }
                        }
                        /*if self.bgAutoTimer.isValid{
                            //print("bg alive")
                            
                        }else if self.isBackground{
                            self.StartBgAutoTimer()
                            }
                        }*/
                        
                        //if self.shakeTime == 3{
                        //self.openTheDoor(true)
                        //}
                    }
                }
            })
        }*/
        ////////
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBG), name: Notification.Name.NSExtensionHostWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterFG), name: Notification.Name.NSExtensionHostDidBecomeActive, object: nil)
        
        isAutoMode = Config.saveParam.bool(forKey: Config.isAutoTag)
        
        if isAutoMode{
        doorCheckButton.setImage(R.image.checkboxTick(), for: .normal)
        //StopScanningTimer()
        StartBgAutoTimer()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        StartScanningTimer()
        if isAutoMode{
            doorCheckButton.setImage(R.image.checkboxTick(), for: .normal)
            //StopScanningTimer()
            StartBgAutoTimer()
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
    
    public override func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let date = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        let disonTime = (minutes * 60) + sec
        Config.saveParam.set(disonTime, forKey: peripheral.identifier.uuidString+"d_time")
        
        isOpenDoor = false
        isAdminEnroll = false
        isEnroll = false
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
//        if !deviceModelStr.contains(Config.deviceSeries){
//            return
//
//        }
        if !Config.deviceSeries.contains(deviceModelStr){
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
        
        
        
        guard let name: String = advertisementData["kCBAdvDataLocalName"] as? String
            
            else{
                print("name= nil")
                return
        }
        let uuid: UUID = peripheral.identifier
        
         let expect_level: Int = readExpectLevelFromDbByUUID(uuid.uuidString);
        print("adv event")
        print("deviceName = \(name)")
        
        if((RSSI.intValue <= 0) && (RSSI.intValue >= Config.BLE_RSSI_MIN)) {
            
            var tmp: DeviceInfo = DeviceInfo(UUID: uuid, name: name, peripheral: peripheral, model: deviceModelStr, customID: customStr, Category: deviceCategoryStr, reserved: devicerReserved, rssi: RSSI.intValue, current_level: Convert_RSSI_to_LEVEL(RSSI.intValue), expect_level: expect_level, alive: 18)
            
            if selectSetDevice == nil && forceDevice == nil{
               selectSetDevice = tmp
               forceDevice = selectSetDevice
            }
            if( deviceInfoList.contains(tmp)) {
                
                let du_idx:Int = deviceInfoList.firstIndex(of: tmp)!
                
                //print("UUID Dulicate!! Index = \(du_idx)")
                
                //AVG RSSI
                let avg_rssi: Int = (RSSI.intValue + deviceInfoList[du_idx].rssi) / 2;
                tmp.rssi = avg_rssi;
                tmp.current_level = Convert_RSSI_to_LEVEL(avg_rssi)
                
            //    print("RSSI: \(RSSI.intValue), LEVEL: \(tmp.current_level)")
                
                deviceInfoList[du_idx] = tmp;
            }
            else {
                deviceInfoList.append(tmp)
                deviceNameLabel.text = deviceInfoList[0].name
                deviceTypeLabel.text = self.GetSimpleLocalizedString("Device Distance") + ":" + "\(deviceInfoList[0].current_level)"
                auto_range_setting.text = self.GetSimpleLocalizedString("Proximity Read Range Settings") + " : " + "\(deviceInfoList[0].expect_level)"  //0316
                
                //Save to DB
                saveExpectLevelToDbByUUID(uuid.uuidString, expect_level)
            }
            if deviceInfoList.count > 0 {
            deviceFoundStatus = .DeviceFound
                changeViewContentSettings()
            }
        }
    
        if !isForce{
            if deviceInfoList.count > 0{
                deviceNameLabel.text = deviceInfoList[0].name
                //增加目前與裝置的距離 20180308
                deviceTypeLabel.text = self.GetSimpleLocalizedString("Device Distance") + ":" + "\(deviceInfoList[0].current_level)"
                auto_range_setting.text = self.GetSimpleLocalizedString("Proximity Read Range Settings") + " : " + "\(deviceInfoList[0].expect_level)"    //0316
            }
        }else{
            if forceDevice.peripheral.identifier.uuidString == uuid.uuidString {
                
                //增加目前與裝置的距離 20180308
                if (deviceInfoList.contains(forceDevice)){
                    let du_idx:Int = deviceInfoList.firstIndex(of: forceDevice)!
                    let avg_rssi: Int = (RSSI.intValue + deviceInfoList[du_idx].rssi) / 2;
                    forceDevice.rssi = avg_rssi;
                    forceDevice.current_level = Convert_RSSI_to_LEVEL(avg_rssi)
                    
                    forceDevice.expect_level = expect_level   //0316
                    
                    deviceInfoList[du_idx] = forceDevice;
                    deviceTypeLabel.text = self.GetSimpleLocalizedString("Device Distance") + ":" + "\(deviceInfoList[du_idx].current_level)"
                    
                    auto_range_setting.text = self.GetSimpleLocalizedString("Proximity Read Range Settings") + " : " + "\(deviceInfoList[du_idx].expect_level)"    //0316
                    
                    
                    deviceNameLabel.text = name
                    forceDevice.peripheral = peripheral
                    forceDevice.name = name
                    
                    
                    
                }
                
                
                
                
//                if deviceNameLabel.text != name{
//                    deviceNameLabel.text = name
//                    forceDevice.peripheral = peripheral
//                    forceDevice.name = name
//                    print("forceDevice = \(forceDevice)")
//
//                }
            }
            
        }
        
        deviceInfoList.sort();
        
        
    }

  
    @objc func didEnterBG(){
        StopScanningTimer()
        for var stopDevice in deviceInfoList{
            let du_idx:Int = deviceInfoList.firstIndex(of: stopDevice)!
            stopDevice.current_level = 999
            deviceInfoList[du_idx] = stopDevice;
            
        }
        
        
        
        print("didEnterBG")
        
        isBackground = true
        
        //Stop Timer
        //StopScanningTimer()
        
        if(isAutoMode) {
            
            //MARK: beginBackgroundTask
            print("Request BackgroundTask !!")
            
            bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                self.backCount = 0
                
               
                self.motionManager.deviceMotionUpdateInterval = 0.02
                self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                    if let acc = data?.userAcceleration.z{
                        if acc > 0.5{
                            self.shakeTime += 1
                            print("ShakeTIme: \(self.shakeTime)")
                            
                            self.delayOnMainQueue(delay: 1, closure: {
                                self.shakeTime = 0
                            })
                            
                            if self.isAutoMode {
                                
                                if !self.isOpenDoor {
                                    print("open door in auto mode")
                                    self.isMotion  =  true
                                }
                                if self.bgAutoTimer.isValid{
                                    //print("bg alive")
                                    
                                }else if self.isBackground{
                                    self.StartBgAutoTimer()
                                }
                            }
                            
                            //if self.shakeTime == 3{
                            //self.openTheDoor(true)
                            //}
                        }
                    }
                })
                //MARK: NEED TODO
                //self.act(.expire)
               // UIApplication.shared.endBackgroundTask(self.bgTaskID!)
            })
            
            //Start Timer
            StartBgAutoTimer();
            
        }
        
    }
    
    @objc func didEnterFG(){
        
        print("didEnterFG")
        
        isBackground = false
        //Start Timer
        StartScanningTimer();
        
        guard isAutoMode else{ return }
        for timer in backgroundTimers{
            timer.invalidate()
        }
        backgroundTimers = []
        
        //Stop Timer
        bgAutoTimer.invalidate()
       
    }
    
    @objc func didTapChooseDevice() {
        //StopScanningTimer()
        var deviceList:[String] = []
        var deviceOBJ:[CBPeripheral] = []
        
        for i in 0 ... deviceInfoList.count - 1{
            deviceOBJ.append(deviceInfoList[i].peripheral)
            deviceList.append(deviceInfoList[i].name)
        }
        let alertController = UIAlertController(title: self.GetSimpleLocalizedString("Please Choose"), message: nil, preferredStyle: .actionSheet)
        for i in 0 ... deviceList.count - 1{
            
            let button = UIAlertAction(title: deviceList[i], style: .default, handler: { (action: UIAlertAction!) in
                
                if self.deviceInfoList.count > 0{
                    print("action.title=\(String(describing: action.title))")
                    if  self.isForce{
                        print("action.title=\(String(describing: action.title))")
                        print("forceDevice.name=\(self.forceDevice.name)")
                        if action.title == self.forceDevice.name {
                        self.selectDeviceIndex = 0
                        self.deviceNameLabel.text = self.deviceInfoList[0].name
                        self.deviceNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                            self.isForce = false
                        }else{
                            for index in 0 ... deviceList.count - 1
                            {
                                if deviceList[index] == action.title{
                                    self.deviceNameLabel.text = action.title
                                    
                                    self.isForce = true
                                    if self.isForce {
                                        self.forceDevice.peripheral = deviceOBJ[index]
                                        self.forceDevice.name = deviceList[index]
                                        self.deviceNameLabel.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                                    }
                                   break
                                    
                                }
                                
                            }

                        }
                    }else{
                        
                        
                        for index in 0 ... deviceList.count - 1
                        {
                            if deviceList[index] == action.title{
                             self.deviceNameLabel.text = action.title
                                
                                 self.isForce = true
                                if self.isForce {
                                    self.forceDevice.peripheral = deviceOBJ[index]
                                self.forceDevice.name = deviceList[index]
                            print("select.title=\(self.forceDevice.name)")
                                    self.deviceNameLabel.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                                }
                                break
                            }
                            
                        }
                     

                    }
                    
                
                }
               self.StartScanningTimer()
            })
            
           
              alertController.addAction(button)
        
        }
        
        let cancelButton = UIAlertAction(title: self.GetSimpleLocalizedString("Cancel"), style: .cancel, handler: { actuion in
            self.updateScanningTimer()
            self.StartScanningTimer()
         }
        )
        
        
     
        alertController.addAction(cancelButton)
        if alertController.popoverPresentationController != nil {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: 1.0,y :1.0), size: CGSize(width: self.view.bounds.size.width / 2.0, height: self.view.bounds.size.height / 2.0))
        }
        
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        
     
    }
    
    @IBAction func didTapOpenDoor(_ sender: Any) {
    
  
        if !isAutoMode {
      if !isOpenDoor{
        //StopScanningTimer()
        
        if deviceInfoList.count > 0 && !isOpenDoor{
        isOpenDoor = true
        let target = GetTargetDevice()
        
            
        //let isAdmin = Config.saveParam.bool(forKey: (target.identifier.uuidString))
        //if isAdmin || checkConTimeLimit(target: target)
       // {
            
            start_anima() //0316
            Config.bleManager.connect(bleDevice: target.peripheral)
            StartConnectTimer()
        //}
            
        switch deviceFoundStatus
        {
        case .DeviceNotFound:
            deviceFoundStatus = .DeviceSearching
            changeViewContentSettings()
        
        case .DeviceFound:
            
//            openDoorButton.setTitle("", for: .normal)
//            openDoorButton.setImage(R.image.tickWhite(), for: .normal)
//            doorButton.setBackgroundImage(R.image.doorOpen(), for: .normal)
//            doorStatusLabel.text = self.GetSimpleLocalizedString("DOOR OPENED")
//            doorStatusLabel.textColor = HexColor("00b900")
//            openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
//            openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            break
            
        default:
            break
        }
        }else{
            //showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
            StartScanningTimer()
        }
            }
        }else{
            showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
            
        }

        
    }
    
    @IBAction func didTapDoorCheck(_ sender: Any) {
        isAutoMode = !isAutoMode
        if isAutoMode{
           
            doorCheckButton.setImage(R.image.checkboxTick(), for: .normal)
            //StopScanningTimer()
            StartBgAutoTimer()
            
        }else{
            
            doorCheckButton.setImage(R.image.checkboxNone(), for: .normal)
            StopBgAutoTimer()
        
        }
        Config.saveParam.set(isAutoMode, forKey: Config.isAutoTag)
        print("didTapDoorCheck")
    }
    
    
    func changeViewContentSettings() {
         //deviceTypeLabel.isHidden = true
        switch deviceFoundStatus
        {
        
        case .DeviceSearching:
            stop_anime()  //0316 stop
            deviceNameLabel.text = GetSimpleLocalizedString("Searching…")
            deviceNameLabel.isUserInteractionEnabled = false
            deviceNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            deviceTypeLabel.text = GetSimpleLocalizedString("Please wait a moment…")
            //deviceTypeLabel.isHidden = true
            dotImageView.isHidden = true
            openDoorButton.setTitle("", for: .normal)
            openDoorButton.setImage(nil, for: .normal)
            openDoorButton.setBackgroundImage(R.image.btnGray(), for: .normal)
            openDoorButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            openDoorButton.isUserInteractionEnabled = false
            doorButton.setBackgroundImage(R.image.doorClose(), for: .normal)
            doorButton.isUserInteractionEnabled = false
            doorStatusLabel.text = self.GetSimpleLocalizedString("DOOR CLOSED")
            doorStatusLabel.textColor = HexColor("a4aab3")
            loadingImageView.isHidden = false
            loadingImageView.rotate360Degree()

        case .DeviceNotFound:
            
            deviceNameLabel.text = "目前找不到裝置"
            deviceNameLabel.isUserInteractionEnabled = false
            deviceTypeLabel.text = "請稍後再試"
            dotImageView.isHidden = true
            openDoorButton.setTitle("", for: .normal)
            openDoorButton.setImage(R.image.researchWhite(), for: .normal)
            openDoorButton.setBackgroundImage(R.image.btnGray(), for: .normal)
            openDoorButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            openDoorButton.isUserInteractionEnabled = true
            doorButton.setBackgroundImage(R.image.doorClose(), for: .normal)
            doorButton.isUserInteractionEnabled = false
            doorStatusLabel.text = self.GetSimpleLocalizedString("DOOR CLOSED")
            doorStatusLabel.textColor = HexColor("a4aab3")
            loadingImageView.isHidden = true
            loadingImageView.stopRotate()
            
        case .DeviceFound:
            
            //deviceNameLabel.text = "E3AK001"
            deviceNameLabel.isUserInteractionEnabled = true
            //deviceTypeLabel.text = "型號ABC123"
            dotImageView.isHidden = false
            openDoorButton.setTitle(self.GetSimpleLocalizedString("OPEN"), for: .normal)
            openDoorButton.setImage(nil, for: .normal)
            openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
            openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            openDoorButton.isUserInteractionEnabled = true
            doorButton.setBackgroundImage(R.image.doorClose(), for: .normal)
            doorButton.isUserInteractionEnabled = true
            doorStatusLabel.text = self.GetSimpleLocalizedString("DOOR CLOSED")
            doorStatusLabel.textColor = HexColor("000000") //a4aab3
            loadingImageView.isHidden = true
            loadingImageView.stopRotate()
            if isForce {
             deviceNameLabel.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
            }
        }
    }
    
    
    
    @IBAction func LongPress(_ sender: Any) {
        if !isAutoMode{
        //StopScanningTimer()
        if deviceInfoList.count > 0 {
           
            let target = GetTargetDevice()
            
            
            let isAdmin = Config.saveParam.bool(forKey: (target.peripheral.identifier.uuidString))
            if isAdmin
            {   if !isKeepOpen{
                isKeepOpen = true
                Config.bleManager.connect(bleDevice: target.peripheral)
                StartConnectTimer()
                }
            }
        }else{
            StartScanningTimer()
           // showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
        }
        }else{
            showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        
        if (segue.identifier == "showSettingsTableViewController") {
            let nvc = segue.destination  as! 
            SettingsTableViewController
            ///let vc = nvc.topViewController as! Intro_PasswordViewController
          
            nvc.selectedDevice = selectSetDevice?.peripheral
            nvc.selectedModel = selectSetDevice?.model
            Config.devCategory = (selectSetDevice?.Category)!
            }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
       
      
        //StopScanningTimer()
        if(isAutoMode){
            print("Need Disable 'AUTO-MODE' First!!")
            showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
            
            return false;
        }
        
        if(isEnroll){
          return false
        }
        
        if deviceInfoList.count > 0{
            selectSetDevice? = GetTargetDevice()
            
            
        let isAdmin = Config.saveParam.bool(forKey: ( selectSetDevice?.peripheral.identifier.uuidString)!)
    
           
            if isAdmin
            {
                return true
            }else{
                var storyboard:UIStoryboard!
                
                storyboard = UIStoryboard(storyboard: .Main)
                let vc:UserSettingsTableViewController =  storyboard.instantiateViewController()
               
               
                vc.selectedDevice = GetTargetDevice()
              
                
               
                vc.current_level_RSSI = GetCurrLevel(targetUUID: (selectSetDevice?.peripheral.identifier.uuidString)!)
                print("c rssi=\(vc.current_level_RSSI)\r\n")
                navigationController?.isNavigationBarHidden = false
                navigationController?.pushViewController(vc, animated: true)
                return false
                 }
            
        }else{
            
           // showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
            StartScanningTimer()
            

          return  false
        }
        
        return true
    }

    public override func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
       super.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
       
        selectSetDevice?.peripheral = peripheral
        connectTimer?.invalidate()
        connectTimer = nil
        if isEnroll{
            if isAdminEnroll {
               Config.bleManager.writeData(cmd: adminEnrollData, characteristic: bpChar)
            }else{
               Config.bleManager.writeData(cmd: userEnrollData, characteristic: bpChar)
            }
        
        }else if isOpenDoor {
            let isAdmin = Config.saveParam.bool(forKey: (selectSetDevice?.peripheral.identifier.uuidString)!)
            var cmd = Data()
            if isAdmin {
            cmd = Config.bpProtocol.setAdminIndentify()
               
            }else{
                let userIndex = Config.saveParam.integer(forKey:(selectSetDevice?.peripheral.identifier.uuidString)! + Config.userIndexTag)
                print("userIndex=\(userIndex)")
                cmd = Config.bpProtocol.setUserIndentify(UserIndex: userIndex)

            }
             Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
        
        }else if isKeepOpen {
          let cmd = Config.bpProtocol.getDeviceConfig()
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
        }
        
       
       // isOpenDoor = false
        //isAdminEnroll = false
        //isEnroll = false
        selectSetDevice?.peripheral.delegate = self

        if disTimer == nil {
            if isKeepOpen{
                
                disTimer = Timer.scheduledTimer(timeInterval: Config.keepDisConTimeOut, target: self, selector: #selector(disconnectTask), userInfo: nil, repeats: false)
            }else{
                disTimer = Timer.scheduledTimer(timeInterval: Config.disConTimeOut, target: self, selector: #selector(disconnectTask), userInfo: nil, repeats: false)
            }
            
            
        }

    }
    
  

    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
      /*   for i in 0 ... cmd.count - 1{
         print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
         }*/
        if datalen == Int16(cmd.count - 4) {
            switch cmd[0]{
                
            case BPprotocol.cmd_admin_enroll:
                var isAdmin = false
                if cmd[4] == BPprotocol.result_success {
                    isAdmin = true
                    showToastDialog(title: "",message: GetSimpleLocalizedString("eroll_success"))
                }else{
                    isAdmin = false
                    showToastDialog(title: "",message: GetSimpleLocalizedString("eroll_fail"))
                }
                Config.saveParam.set(isAdmin, forKey:
                    (selectSetDevice?.peripheral.identifier.uuidString)!)
                
                //self.backToMainPage()
                break
                
            case BPprotocol.cmd_user_enroll:
                
                if datalen > 1 {
                    let userIndex:Int = Int(UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    
                    print("userIndex=\(userIndex)")
                    Config.saveParam.set(userIndex, forKey: (selectSetDevice?.peripheral.identifier.uuidString)! + Config.userIndexTag)
                    Config.saveParam.set(false, forKey: (selectSetDevice?.peripheral.identifier.uuidString)!)
                    showToastDialog(title: "",message: GetSimpleLocalizedString("eroll_success"))
                }else{
                    showToastDialog(title: "",message: GetSimpleLocalizedString("eroll_fail"))
                }
                
                break
            case BPprotocol.cmd_admin_identify:
                if(!isAutoMode){
                    switch(cmd[4]){
                        
                        
                    case BPprotocol.open_fail_PD:
                        showToastDialog(title: "",message: GetSimpleLocalizedString("open_fail_permission_denied"))
                        break
                        
                    case BPprotocol.open_fail_no_eroll:
                        showToastDialog(title: "",message: GetSimpleLocalizedString("open_fail_no_eroll"))
                        break
                        
                        
                    default:
                        print("")
                        StopScanningTimer()
                        openDoorButton.setTitle("", for: .normal)
                        openDoorButton.setImage(R.image.tickWhite(), for: .normal)
                        doorButton.setBackgroundImage(R.image.doorOpen(), for: .normal)
                        doorStatusLabel.text = self.GetSimpleLocalizedString("DOOR OPENED")
                        doorStatusLabel.textColor = HexColor("00b900")
                        openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
                        openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+5, execute:
                            {
                                self.deviceFoundStatus = .DeviceFound
                                self.changeViewContentSettings()
                                self.StartScanningTimer()
                        })
                        
                    }
                    
                }
                break
                
            case BPprotocol.cmd_user_identify:
                if(!isAutoMode){
                    switch(cmd[4]){
                        
                        
                    case BPprotocol.open_fail_PD:
                        showToastDialog(title: "",message: GetSimpleLocalizedString("open_fail_permission_denied"))
                        break
                        
                    case BPprotocol.open_fail_no_eroll:
                        showToastDialog(title: "",message: GetSimpleLocalizedString("open_fail_no_eroll"))
                        break
                        
                        
                    default:
                        print("")
                        StopScanningTimer()
                        openDoorButton.setTitle("", for: .normal)
                        openDoorButton.setImage(R.image.tickWhite(), for: .normal)
                        doorButton.setBackgroundImage(R.image.doorOpen(), for: .normal)
                        doorStatusLabel.text = self.GetSimpleLocalizedString("DOOR OPENED")
                        doorStatusLabel.textColor = HexColor("00b900")
                        openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
                        openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+5, execute:
                            {
                                self.deviceFoundStatus = .DeviceFound
                                self.changeViewContentSettings()
                                self.StartScanningTimer()
                        })
                        
                    }
                }
                break
                
            case BPprotocol.cmd_device_config:
                var cmdData = Data()
                for i in 0 ... cmd.count - 5{
                  cmdData.append(cmd[i+4])
                }
                if cmd[1] == BPprotocol.type_read{
                    if cmd[5] == BPprotocol.door_status_KeepOpen {
                        print("keepOpen\r\n")
                        cmdData[1] = UInt8(BPprotocol.door_status_delayTime)
                        
                    }else {
                       cmdData[1] = UInt8(BPprotocol.door_status_KeepOpen)
                        print("delay\r\n")
                    }
                    
                    for j in 0 ... cmd.count - 1 {
                        
                        print(String(format:"%02X",cmd[j]))
                    }
                    
                    
                    
                    let newCmd = Config.bpProtocol.setDeviceConfig(door_option: cmdData[0], lockType: cmdData[1], delayTime: Int16(UInt16(cmdData[2]) * 256 + UInt16(cmdData[3])), G_sensor_option: cmdData[4])
                        Config.bleManager.writeData(cmd: newCmd, characteristic: bpChar)
                    
                }else if cmd[1] == BPprotocol.type_write{
                    isKeepOpen = false

                }
                break
                
            case BPprotocol.cmd_fw_version:
                if cmd[1] == BPprotocol.type_read{
                    
                    var data = [UInt8]()
                    for i in 4 ... cmd.count - 1{
                        data.append(cmd[i])
                    }
                    let major = data[0]
                    let minor = data[1]
                    
                    if major == 1 && minor >= 6{
                        Config.bleManager.disconnectByCMD(char: bpChar)
                    }
                    else{
                        Config.bleManager.disconnect()
                        
                    }
                    print("disconnection ok\r\n")
                    let date = Date()
                    let calendar = Calendar.current
                    let minutes = calendar.component(.minute, from: date)
                    let sec = calendar.component(.second, from: date)
                    let disonTime = (minutes * 60) + sec
                    Config.saveParam.set(disonTime, forKey: (selectSetDevice?.peripheral.identifier.uuidString)!+"d_time")
                    

                    isOpenDoor = false
                    isAdminEnroll = false
                    isEnroll = false
                    if isAutoMode{
                       bgAutoTimerFlag = true
                    }else{
                        print("start scanning timer")
                        
//                     StartScanningTimer()
                    }
                    //isMotion = false
                    //self.backToMainPage()
                }
                
                break
            default:
                break
                
            }

        }
        stop_anime() //0316 stop
        
    }
    
    func disconnect() {
        
       
        //peripheral.delegate = nil
        //self.peripheral = nil
        
        let cmd = Config.bpProtocol.getFW_version()
        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
       
    }

    @objc func disconnectTask(){
        stop_anime() //0316 stop
         isKeepOpen = false
        print("disconnect time out");
       
        disconnect()
        disTimer = nil
    }
    @objc func connectTimeOutTask(){
        isKeepOpen = false
        isOpenDoor = false
        isEnroll = false
        isAdminEnroll = false
        print("connect time out");
        Config.bleManager.disconnect()
        connectTimer = nil
        if isAutoMode{
          bgAutoTimerFlag = true
          
        }else{
       
        deviceFoundStatus = .DeviceSearching
        changeViewContentSettings()
            
            StartScanningTimer()
        }
    }

    func GetTargetDevice()->DeviceInfo{
        var targetDevice:DeviceInfo?
        
        if isForce{
            /*if selectDeviceIndex < deviceInfoList.count{
                if isExistTarget(targetUUID: forceDevice.identifier.uuidString){
                    targetDevice = forceDevice
                }
            }else{
               targetDevice = deviceInfoList[selectDeviceIndex].peripheral
            }*/
            targetDevice = forceDevice
            print("get device name=\(String(describing: targetDevice?.name))")
        }else{
            
            var current_level = deviceInfoList[0].current_level
             targetDevice = deviceInfoList[0]
            
            for i in 0 ... deviceInfoList.count - 1{
                if deviceInfoList[i].current_level < current_level{
                    
                    targetDevice = deviceInfoList[i]
                    current_level = deviceInfoList[i].current_level
                }
            }
        }
    
      return targetDevice!
    }
    
    func StartBgAutoTimer() {
        
        //Create Timer
        bgAutoTimerFlag = true
        bgAutoTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateBgAutoTimer), userInfo: nil, repeats: true)
    }
    func StopBgAutoTimer(){
        bgAutoTimerFlag = false
        bgAutoTimer.invalidate()
    }
    
    @objc func updateBgAutoTimer() {
    
        
    var selectTarget:DeviceInfo!
    if bgAutoTimerFlag {
              //rtrerrrr  print("updateBgAutoTimer()")
        var isTriggerOpendoor = false
        if deviceInfoList.count > 0 && !isOpenDoor{
//            Config.bleManager.ScanBLEStop()
        selectTarget = GetTargetDevice()
           isTriggerOpendoor = checkConTimeLimit(target: selectTarget.peripheral)
        }
        
        if(isTriggerOpendoor) {
            //print(" ---- isBackGround-AutoMode ---- ")
        

                
                let expectLEVEL = readExpectLevelFromDbByUUID(selectTarget.peripheral.identifier.uuidString)
                //print("expectLEVEL=: \(expectLEVEL )")
                let currentLEVEL = GetCurrLevel(targetUUID: selectTarget.peripheral.identifier.uuidString)
              print("expectLEVEL=: \(expectLEVEL )")
             print("currentLEVEL=: \(currentLEVEL )")
                if expectLEVEL >= currentLEVEL{
                    
                    start_anima() //0316
                    
                    Config.bleManager.connect(bleDevice: selectTarget.peripheral)
                    StartConnectTimer()
                    isOpenDoor = true
                    bgAutoTimerFlag = false
                  }
                }
        
            print("Scan-CNT: \(deviceInfoList.count)")
        
        
       
      
        }else if (!isOpenDoor){
           Config.bleManager.ScanBLE()
           checkDeviceAlive()
         }
    }

    func isExistTarget(targetUUID:String)->Bool{
        
        
        if deviceInfoList.count > 0{
        for i in 0 ... deviceInfoList.count - 1{
            if deviceInfoList[i].UUID.uuidString == targetUUID{
               return true
              }
            }
        }
        
        return false
    }
    
    func StartScanningTimer() {
        
        //防止timer重複疊加 在開始前先停止 20180309
        StopScanningTimer()
        
        //Create Timer
        Config.bleManager.ScanBLE()
        ScanningTimerflag = true
        scanningTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateScanningTimer), userInfo: nil, repeats: true)
    }
    func StopScanningTimer(){
       ScanningTimerflag = false
       Config.bleManager.ScanBLEStop()
       scanningTimer.invalidate()
       
        
    }
    func GetCurrLevel(targetUUID:String)->Int{
      
        
        if deviceInfoList.count > 0{
            for i in 0 ... deviceInfoList.count - 1{
                if deviceInfoList[i].UUID.uuidString == targetUUID{
                    return deviceInfoList[i].current_level
                    
                }
            }
        }
      return 0
    }
    func checkDeviceAlive(){
    
        var need_remove_array: [Int] = []
        var need_Check_Alive: Bool = true;
        
        if(Config.bleManager.isScanBLE()) {
           
            need_Check_Alive = true;
        }
        else {
            need_Check_Alive = false;
            
            Config.bleManager.ScanBLE()
        }
        
        //print("Update - Timer")
        
        if( need_Check_Alive) {
            
            for index in 0..<deviceInfoList.count  {
                 //print(" [\(deviceInfoList[index].name)]")
                 //print(" alive=[\(deviceInfoList[index].alive)]")
                deviceInfoList[index].alive -= 1;
               
                if(deviceInfoList[index].alive <= 0) {
                    //print("Remove [\(deviceInfoList[index].name)]")
                    
                    need_remove_array.append(index)
                }
            }
            
            for remove_idx in 0..<need_remove_array.count {
                let remove_idx: Int = need_remove_array[remove_idx];
                
                //print("remove idx \(remove_idx)")
                if deviceInfoList.count > remove_idx {
                    deviceInfoList.remove(at: remove_idx)
                }
            }
        }
    
        print(String(format:"check alive device cnt=%d",deviceInfoList.count))
    
    }
    
    @objc func updateScanningTimer() {
        if ScanningTimerflag{
            //Config.bleManager.ScanBLE()
            checkDeviceAlive()
            if !(deviceInfoList.count > 0) {
                deviceFoundStatus = .DeviceSearching
                changeViewContentSettings()
                
            }
        }
       
    }
    

    
    func checkConTimeLimit(target:CBPeripheral)->Bool{
        var res:Bool = false
        let date = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        let currentTime = (minutes * 60) + sec
        let disConTime = Config.saveParam.integer(forKey: (target.identifier.uuidString)+"d_time")
        print("disT=\(disConTime), currT=\(currentTime)")
        if ((abs(currentTime - disConTime)) > Int(Config.auto_disConTimeOut)){
            res = true
        }
        
        return res
    }
    
    func StartConnectTimer(){
        if connectTimer == nil {
            
            connectTimer = Timer.scheduledTimer(timeInterval: Config.ConTimeOut, target: self, selector: #selector(connectTimeOutTask), userInfo: nil, repeats: false)
            
            
        }

    }
    
    
    
    func start_anima()  {
        self.infoOperation.isHidden = false
        var rotationAnimation: CABasicAnimation?
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation?.toValue = .pi * 2.0
        rotationAnimation?.duration = 0.5
        rotationAnimation?.repeatCount = Float.greatestFiniteMagnitude
        if let aAnimation = rotationAnimation{
            self.infoOperation.layer.add(aAnimation, forKey: "rotationAnimation")
        }
        
    }
    
    func stop_anime() {
        self.infoOperation.layer.removeAllAnimations()
        self.infoOperation.isHidden = true
    }
    
    
    
    
}
