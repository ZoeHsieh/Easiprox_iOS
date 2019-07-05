//
//  Intro_PasswordViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/7.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework
import IQKeyboardManagerSwift
import CoreBluetooth

enum RegisteredStatus {
    case Registered
    case NotRegistered
}

class Intro_PasswordViewController: BLE_ViewController, UITextFieldDelegate {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var passwordTopLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingView: UIImageView!
    
    var registeredStatus: RegisteredStatus = .NotRegistered
    var selectedDevice:CBPeripheral!
    var connectTimer:Timer? = nil
    var isAdminEnroll:Bool = false
    var isEnroll:Bool = false
    var userEnrollData: Data!
    var adminEnrollData: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightButton.setTitle(self.GetSimpleLocalizedString("Skip"), for: .normal)
        accountTextField.placeholder = self.GetSimpleLocalizedString("Your ID")
        passwordTextField.placeholder = self.GetSimpleLocalizedString("Password")
        nextButton.setTitle(self.GetSimpleLocalizedString("Next"), for: .normal)
        noteLabel.text = self.GetSimpleLocalizedString("If you forgot your ID or password, please contact your administrator.")
        
        rightButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
        //passwordTextField.becomeFirstResponder()
        //passwordTextField.delegate = self
        passwordTextField.keyboardType = .numberPad
        passwordTextField.addTarget(self, action: #selector(TextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        deviceNameLabel.text = selectedDevice.name
        helloLabel.text = self.GetSimpleLocalizedString("Enroll User")
        accountTextField.becomeFirstResponder()
        accountTextField.isHidden = false
        accountTextField.isUserInteractionEnabled = true
        accountTextField.addTarget(self, action: #selector(TextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        passwordTopLayoutConstraint.constant = 8
        noteLabel.text = self.GetSimpleLocalizedString("if you forgot your ID or password, please contact your administrator")//"密碼請參閱說明書"
        registeredStatus = .NotRegistered
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        loadingView.isHidden = true
        nextButton.isUserInteractionEnabled = true
        nextButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
        nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
          }
    public override func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        
    }
    
   
    public override func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        super.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
       selectedDevice = peripheral
        connectTimer?.invalidate()
        connectTimer = nil
      
            if isAdminEnroll {
                Config.bleManager.writeData(cmd: adminEnrollData, characteristic: bpChar)
            }else{
                Config.bleManager.writeData(cmd: userEnrollData, characteristic: bpChar)
            }
            
       
        isAdminEnroll = false
        
    }
    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        /* for i in 0 ... cmd.count - 1{
         print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
         }*/
        if datalen == Int16(cmd.count - 4) {
            switch cmd[0]{
                
            case BPprotocol.cmd_admin_enroll:
                var isAdmin = false
                if cmd[4] == BPprotocol.result_success {
                    isAdmin = true
                   
                }else{
                    isAdmin = false
                }
                Config.saveParam.set(isAdmin, forKey:
                   selectedDevice.identifier.uuidString)
                if isAdmin{
                    let cmd = Config.bpProtocol.getUserCount()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
                }else{
                    Config.bleManager.disconnect()
                    loadingView.isHidden = true
                    nextButton.setTitle(self.GetSimpleLocalizedString("Next"), for: .normal)
                    nextButton.isUserInteractionEnabled = true
                    nextButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
                    nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
                }
                break
                
            case BPprotocol.cmd_user_enroll:
                
                if cmd[4] == BPprotocol.result_success {
                    
                    let userIndex:Int = Int(UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    
                    print("userIndex=\(userIndex)")
                    Config.saveParam.set(userIndex, forKey:selectedDevice.identifier.uuidString + Config.userIndexTag)
                    Config.saveParam.set(false, forKey: selectedDevice.identifier.uuidString)
                    
                    selectedDevice.readRSSI()
                    
                }else{
                    Config.bleManager.disconnect()
                    loadingView.isHidden = true
                    nextButton.setTitle(self.GetSimpleLocalizedString("Next"), for: .normal)
                    nextButton.isUserInteractionEnabled = true
                    nextButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
                    nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
                
                }
                
                break
           
            case BPprotocol.cmd_user_counter:
                
                if cmd[4] == BPprotocol.result_success {
                    let userMax = Int(Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF)))
                    
                    if userMax <= 0{
                        
                        
                        let cmd = Config.bpProtocol.getAdminPWD()
                        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
                       
                       
                    }else{
                          selectedDevice.readRSSI()
                    }
                    
                    
                }else{
                    selectedDevice.readRSSI()
                }
                break
                
            case BPprotocol.cmd_set_admin_pwd:
                
                for i in 0 ... cmd.count - 1{
                    print(String(format:"cmd[%d]=%02x",i,cmd[i]))
                }
                if cmd[1] == BPprotocol.type_read{
                    
                        var data = [UInt8]()
                        for i in 4 ... cmd.count - 1{
                            data.append(cmd[i])
                        }
                        var PWDArray = [UInt8]()
                        
                        for j in 0 ... BPprotocol.userPD_maxLen - 1{
                            if  data[j] != 0xFF && data[j] != 0x00{
                                PWDArray.append(data[j])
                            }
                        }
                        let pwd = String(bytes: PWDArray, encoding: .ascii) ?? "12345"
                        
                        print(pwd)
                        Config.ADMINPWD = pwd
                        let vc = storyboard?.instantiateViewController(withIdentifier :"Intro_UserViewController") as! Intro_UserViewController
                        vc.selectedDevice = selectedDevice
                        vc.bpChar = self.bpChar
                        navigationController?.pushViewController(vc, animated: true)
                    
                }
                
                break

             default:
                break
                
            }
            
        }
        
    }
    
    override func peripheral(_ peripheral: CBPeripheral,
                             didReadRSSI RSSI: NSNumber,
                             error: Error?) {
        let rssi = RSSI.intValue
        let vc = storyboard?.instantiateViewController(withIdentifier :"Intro_DistanceSettingsViewController") as! Intro_DistanceSettingsViewController
       
        vc.selectedDevice = selectedDevice
         vc.bpChar = self.bpChar
        navigationController?.pushViewController(vc, animated: true)
        Config.bleManager.disconnect()
        print("rssi = \(rssi)")
       vc.rssiCurrentLevel = String(format:"%d",Convert_RSSI_to_LEVEL(rssi))
    }
    

   /* func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("shouldChangeCharactersIn ")

        if textField == accountTextField{
            print("accountText field ")
         if( (textField.text?.characters.count)! > 6 ){
                textField.deleteBackward();
            }
        }
        /* else if textField == passwordTextField{
            if ( (textField.text?.characters.count)! > 6 ) {
                textField.deleteBackward();
            }
            
        }*/
        

       /* let countOfWords = string.characters.count +  textField.text!.characters.count - range.length*/
        
        if ((accountTextField.text?.characters.count)! >= 1) && ((passwordTextField.text?.characters.count)! >= 4)
        {   print("check ok ")
            nextButton.isUserInteractionEnabled = true
            nextButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
            nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        }
        else
        {  print("check fail")
            nextButton.isUserInteractionEnabled = false
            nextButton.setBackgroundImage(R.image.btnGray(), for: .normal)
            nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        }
        
        return true
    }*/
    /*
    @IBAction func didTapRegistered(_ sender: Any) {
        
        helloLabel.text = self.GetSimpleLocalizedString("Hello!")
        accountTextField.isHidden = true
        accountTextField.isUserInteractionEnabled = false
        passwordTopLayoutConstraint.constant = -29
        noteLabel.text = self.GetSimpleLocalizedString("if you forgot your ID or password, please contact your administrator")
        registeredStatus = .Registered
    }
    
    @IBAction func didTapNotRegistered(_ sender: Any) {
        
        helloLabel.text = self.GetSimpleLocalizedString("Enroll User")
        accountTextField.isHidden = false
        accountTextField.isUserInteractionEnabled = true
        passwordTopLayoutConstraint.constant = 8
        noteLabel.text = self.GetSimpleLocalizedString("if you forgot your ID or password, please contact your administrator")//"密碼請參閱說明書"
        registeredStatus = .NotRegistered
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func TextFieldDidChange(field: UITextField){
        
        
        if field == accountTextField{
           // print("accountText field ")
            if( (field.text?.utf8.count)! > 16 ){
                field.deleteBackward();
            }
        }
         else if field == passwordTextField{
         if ( (field.text?.count)! > 8 ) {
             field.deleteBackward();
         }
         
         }
        
        
        /* let countOfWords = string.characters.count +  textField.text!.characters.count - range.length*/
        
        if ((accountTextField.text?.count)! >= 1) && ((passwordTextField.text?.count)! >= 4)
        {
            nextButton.isUserInteractionEnabled = true
            nextButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
            nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        }
        else
        {
            nextButton.isUserInteractionEnabled = false
            nextButton.setBackgroundImage(R.image.btnGray(), for: .normal)
            nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        }

       
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("test2")
        if (segue.identifier == "intro_") {
            let nvc = segue.destination  as! Intro_PasswordViewController
            
            ///let vc = nvc.topViewController as! Intro_PasswordViewController
            nvc.selectedDevice = selectedDevice
          
        }
        
    }
    func StartConnectTimer(){
        if connectTimer == nil {
            
            connectTimer = Timer.scheduledTimer(timeInterval: Config.ConTimeOut, target: self, selector: #selector(connectTimeOutTask), userInfo: nil, repeats: false)
            
            
        }
        
    }
    @objc func connectTimeOutTask(){
        
        
        
        print("connect time out");
        Config.bleManager.disconnect()
        connectTimer = nil
         loadingView.isHidden = true
        nextButton.setTitle(self.GetSimpleLocalizedString("Next"), for: .normal)
        nextButton.isUserInteractionEnabled = true
        nextButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
        nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
    }
    @IBAction func next(_ sender: Any) {
        let userID:[UInt8] = Util.StringtoUINT8(data: accountTextField.text!, len: BPprotocol.userID_maxLen, fillData: BPprotocol.nullData)
        let userPWD:[UInt8] = Util.StringtoUINT8(data: passwordTextField.text!, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
        
        if accountTextField.text == Config.AdminID{
            //print("admin enroll");
            self.adminEnrollData = Config.bpProtocol.setAdminEnroll(UserID: userID,Password: userPWD)
            self.isAdminEnroll = true
            
        }
        else{
            self.userEnrollData = Config.bpProtocol.setUserEnroll(UserID: userID, Password: userPWD)
            //print("user enroll");
        }
           Config.bleManager.connect(bleDevice: selectedDevice)
            StartConnectTimer()
        loadingView.isHidden = false
        nextButton.setTitle(self.GetSimpleLocalizedString(""), for: .normal)
        loadingView.rotate360Degree()
        nextButton.isUserInteractionEnabled = false
        nextButton.setBackgroundImage(R.image.btnGray(), for: .normal)
        nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)

        
    }

}
