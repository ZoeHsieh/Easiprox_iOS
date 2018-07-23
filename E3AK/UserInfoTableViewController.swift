//
//  UserInfoTableViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/15.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import UIAlertController_Blocks
import CoreBluetooth

class UserInfoTableViewController: BLE_tableViewController , UITextFieldDelegate{
    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var cardTextField: UITextField!
    
    @IBOutlet weak var label_accessLimit: UILabel!
    
    
    @IBOutlet weak var cardSwitch: UISwitch!
    @IBOutlet weak var cardSwitchTitle: UILabel!
    @IBOutlet weak var phoneSwitch: UISwitch!
    @IBOutlet weak var phoneSwitchTitle: UILabel!
    @IBOutlet weak var keypadSwitch: UISwitch!
    @IBOutlet weak var keypadSwitchTitle: UILabel!
    @IBOutlet weak var accessTypeTitle: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var EditCardDialogTitle: UILabel!
    
    @IBOutlet weak var CardDialogCancelBtn: UIButton!
    
    
    @IBOutlet weak var CardDialogConfirmBtn: UIButton!
    
    @IBOutlet var CardDialogFrame: UIView!
    
    @IBOutlet weak var CardDialogView: UIView!
    
    @IBOutlet weak var CardInput1: UITextField!
    
    @IBOutlet weak var CardInput2: UITextField!
    
    
    @IBOutlet weak var CardInput3: UITextField!
    
    @IBOutlet weak var CardInput4: UITextField!
    
    
    @IBOutlet weak var CardInput5: UITextField!
    
    @IBOutlet weak var CardInput6: UITextField!
    
    @IBOutlet weak var CardInput7: UITextField!
    
    @IBOutlet weak var CardInput8: UITextField!
    
    @IBOutlet weak var CardInput9: UITextField!
    
    
    @IBOutlet weak var CardInput10: UITextField!
    
    
    var selectUser:Int = 0
    var userIndex :Int16 = 0
    var isEnableStatus:UInt8 = 0x00
    static var tmpCMD = Data()
    static var isSettingAccess = false
    static var titleForFooter:String =  ""
    var limitType: UInt8!
    var startTimeArr: Array<Int>!
    var endTimeArr: Array<Int>!
    var openTimes: Int!
    var weekly: UInt8!
    var displayAlerDialog:UIAlertController? = nil
    // var newStartTimeArr = [Date().year, Date().month, Date().day, 0, 0, 0]
    // var newEndTimeArr = [Date().year + 1, Date().month, Date().day, 23, 50, 0]
    @IBAction func CardConfirmBtnListener(_ sender: Any) {
        
        var cardNum = 0
        let CardInputs = [ CardInput1,CardInput2,
                           CardInput3, CardInput4,
                           CardInput5,CardInput6,
                           CardInput7,CardInput8,
                           CardInput9, CardInput10]
        var newCard = ""
        for i in 0 ... CardInputs.count - 1{
            if CardInputs[i]?.text != " "{
                newCard += (CardInputs[i]?.text)!
                
                cardNum +=   (CardInputs[i]?.text?.characters.count)!
                
            }
        }
        if newCard == "" && cardNum == 0{
            newCard = BPprotocol.spaceCardStr
        }
        self.CardDialogFrame.removeFromSuperview();
        print("cardNum = \(cardNum) newCard=\(newCard)")
        if (cardNum != 0) && (cardNum != 10 ){
            
            self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_card"))
            return
        }
        
        if(newCard != BPprotocol.spaceCardStr){
            
            guard UInt32(newCard) != nil
                
                else{
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_card"))
                    return
            }
            
            if newCard == BPprotocol.INVALID_CARD{
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_card"))
                return
            }
            
            
            
            let cardArr = Config.userListArr.map{ $0["card"] as! String }
            
            
            if cardArr.contains(newCard){
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_card"))
                return
            }
            
            
            if newCard == Config.ADMINCARD {
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_card"))
                return
            }
            
            
            
            let cardUint8 = Util.StringDecToUINT8(data: newCard, len: (newCard.characters.count))
            
            
            
            
            
            let cmd = Config.bpProtocol.setUserCard(UserIndex: self.userIndex, Card: cardUint8)
            Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
            UserInfoTableViewController.tmpCMD = cmd
            
            
        }else{
            
            let cardData:[UInt8] = [0xFF,0xFF,0xFF,0xFF]
            let cmd = Config.bpProtocol.setUserCard(UserIndex: self.userIndex,Card: cardData)
            Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
            UserInfoTableViewController.tmpCMD = cmd
            
        }
        
        
        
        
        
        self.CardDialogFrame.removeFromSuperview();
    }
    
    
    
    @IBAction func CardCancelBtnListener(_ sender: Any) {
        
        self.CardDialogFrame.removeFromSuperview();
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = GetSimpleLocalizedString("User Info")
        //recurrentLabel.text = "Recurrent".localized()
        accountTextField.placeholder = GetSimpleLocalizedString("Please Provide Up to 16 characters")
        passwordTextField.placeholder = GetSimpleLocalizedString("4~8 digits")
        
        cardTextField.placeholder = GetSimpleLocalizedString("10 digits")
        
        phoneSwitchTitle.text = GetSimpleLocalizedString("Phone Access")
        
        cardSwitchTitle.text = GetSimpleLocalizedString("Card Access")
        
        keypadSwitchTitle.text = GetSimpleLocalizedString("Keypad Access")
        deleteButton.setTitle(GetSimpleLocalizedString("Delete"), for: .normal)
        accessTypeTitle.text = GetSimpleLocalizedString("Access Types/Schedule")
        accountTextField.setTextFieldPaddingView()
        accountTextField.isUserInteractionEnabled = false
        // accountTextField.addTarget(self, action: #selector(UserInfoTableViewController.didTapID), for: .touchUpOutside)
        passwordTextField.setTextFieldPaddingView()
        passwordTextField.isUserInteractionEnabled = false
        //passwordTextField.addTarget(self, action: #selector(UserInfoTableViewController.didTapPWD), for: .editingDidBegin)
        cardTextField.setTextFieldPaddingView()
        cardTextField.isUserInteractionEnabled = false
        phoneSwitch.isUserInteractionEnabled = false
        cardSwitch.isUserInteractionEnabled = false
        keypadSwitch.isUserInteractionEnabled = false
        
        userIndex = Config.userListArr[selectUser]["index"] as! Int16
        passwordTextField.text = Config.userListArr[selectUser]["pw"] as? String
        accountTextField.text = Config.userListArr[selectUser]["name"] as? String
        cardTextField.text = Config.userListArr[selectUser]["card"] as? String
        
        if Config.deviceType == Config.deviceType_Card{
            
            keypadSwitchTitle.isHidden = true
            keypadSwitch.isHidden = true
            
        }else  if Config.deviceType == Config.deviceType_Keypad{
            
            cardSwitch.isHidden = true
            cardSwitchTitle.isHidden = true
        }
        
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        let cmd = Config.bpProtocol.getUserProperty(UserIndex: Int16(userIndex))
        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        if UserInfoTableViewController.isSettingAccess{
            let cmd = UserInfoTableViewController.tmpCMD
            print(String(format:"cmd1 cnt=%d", cmd.count))
            
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
            UserInfoTableViewController.isSettingAccess = false
        }
        
        tableView.reloadData()
        
    }
    
    @IBAction func didTapDelete(_ sender: Any) {
        UIAlertController.showAlert(
            in: self,
            withTitle: GetSimpleLocalizedString("Delete User?"),
            message: nil,
            cancelButtonTitle: GetSimpleLocalizedString("Cancel"),
            destructiveButtonTitle: nil,
            otherButtonTitles: [GetSimpleLocalizedString("Confirm")],
            tap: {(controller, action, buttonIndex) in
                if (buttonIndex == controller.cancelButtonIndex) {
                    print("Cancel Tapped")
                } else if (buttonIndex == controller.destructiveButtonIndex) {
                    print("Delete Tapped")
                } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                    //print("Other Button Index \(buttonIndex - controller.firstOtherButtonIndex)")
                    //Config.userDeleted = self.id
                    let cmdData = Config.bpProtocol.setUserDel(UserIndex: self.userIndex)
                    Config.bleManager.writeData(cmd: cmdData,characteristic:self.bpChar!)
                    
                    
                }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section)
        {
        case 2:
            if(Config.deviceType == Config.deviceType_Keypad){
                return 0
            }else{
                return 1
            }
        case 3:
            
            return 4
            
        default:
            return 1;
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.black        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return GetSimpleLocalizedString("ID")
        case 1:
            return GetSimpleLocalizedString("Password/PIN Code (4~8 Digits)")
        case 2:
            if(Config.deviceType != Config.deviceType_Keypad){
                return GetSimpleLocalizedString("Card")
            }else{
                return ""
                
            }
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
        case 3:
            return UserInfoTableViewController.titleForFooter
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        if indexPath.section == 0{
            
            didTapID()
        }else if indexPath.section == 1{
            didTapPWD()
        }
        else if indexPath.section == 2{
            didTapCard()
        }
        else if indexPath.section == 3 && indexPath.row == 0
        {
            var cmd = Data()
            if isEnableStatus & BPprotocol.enable_phone == BPprotocol.enable_phone
            {  isEnableStatus -= BPprotocol.enable_phone
                
                cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
            }else{
                isEnableStatus += BPprotocol.enable_phone
                cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                
            }
            UserInfoTableViewController.tmpCMD = cmd
            
        }else if indexPath.section == 3 && indexPath.row == 1
        {  if Config.deviceType != Config.deviceType_Keypad{
            var cmd = Data()
            if isEnableStatus & BPprotocol.enable_card == BPprotocol.enable_card
            {   isEnableStatus -= BPprotocol.enable_card
                cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
            }else{
                isEnableStatus += BPprotocol.enable_card
                cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                
            }
            UserInfoTableViewController.tmpCMD = cmd
            }
        }else if indexPath.section == 3 && indexPath.row == 2
        {
            if Config.deviceType != Config.deviceType_Card{
                var cmd = Data()
                if isEnableStatus & BPprotocol.enable_keypad == BPprotocol.enable_keypad
                {   isEnableStatus -= BPprotocol.enable_keypad
                    cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                    Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                }else{
                    isEnableStatus += BPprotocol.enable_keypad
                    cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                    Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                    
                }
                UserInfoTableViewController.tmpCMD = cmd
            }
        }
            
        else if indexPath.section == 3 && indexPath.row == 3
        {
            let vc = AccessTypesViewController(nib:R.nib.accessTypesViewController)
            AccessTypesViewController.startTimeArr = self.startTimeArr
            AccessTypesViewController.endTimeArr = self.endTimeArr
            AccessTypesViewController.openTimes = self.openTimes
            AccessTypesViewController.weekly = self.weekly
            vc.isEnableStatus = self.isEnableStatus
            if limitType == 0x00{
                vc.accessType = .Permanent
            }else if limitType == 0x03{
                vc.accessType = .Recurrent
            }else if limitType == 0x02{
                vc.accessType = .AccessTimes
            }else if limitType == 0x01{
                vc.accessType = .Schedule
            }
            vc.userIndex = self.userIndex
            vc.limitType = self.limitType
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    func didTapID() {
        
        displayAlerDialog = alertWithTextField(title: self.GetSimpleLocalizedString("users_id_edit_dialog_title"), subTitle: "",  placeHolder: self.GetSimpleLocalizedString("Up to 16 characters"), keyboard: .default, defaultValue: accountTextField.text! ,Tag: 0,handler: { (inputText) in
            
            guard var newName: String = inputText else{
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("Wrong format!"))
                
                return
            }
            print(newName)
            
            if newName.utf8.count > 16{
                
                repeat{
                    var chars = newName.characters
                    chars.removeLast()
                    newName = String(chars)
                }while newName.utf8.count > 16
            }
            
            let nameArr = Config.userListArr.map{ $0["name"] as! String }
            
            print("name size = \(nameArr.count)")
            if nameArr.contains((newName)){
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_name"))
                return
            }
            print("user name =\(newName)")
            if newName.localizedUppercase == Config.AdminID || newName.localizedUppercase == "ADMIN"{
                print("revise id fail")
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_name"))
                return
            }
            print("123")
            
            let nameUint8 = Util.StringtoUINT8ForID(data: newName, len: 16, fillData: BPprotocol.nullData)
            
            
            let cmd = Config.bpProtocol.setUserID(UserIndex: Int16(self.userIndex), ID: nameUint8)
            
            Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
            UserInfoTableViewController.tmpCMD = cmd
        })
        
    }
    
    func didTapPWD() {
        displayAlerDialog = alertWithTextField(title: self.GetSimpleLocalizedString("users_pwd_edit_dialog_title"), subTitle: "", placeHolder: self.GetSimpleLocalizedString("4~8 digits"), keyboard: .numberPad, defaultValue: passwordTextField.text!, Tag: 1, handler: { (inputText) in
            guard let newPWD: String = inputText else{
                
                //self.showAlert(message: "Wrong format!")
                return
            }
            if !((inputText?.isEmpty)!){
                guard (inputText?.characters.count)! > 3 && (inputText?.characters.count)! < BPprotocol.userPD_maxLen+1 else{
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_pwd"))
                    return
                }
                
                let pwArr = Config.userListArr.map{ $0["pw"] as! String }
                
                
                if pwArr.contains(inputText!){
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_password"))
                    return
                }
                
                if inputText! == Config.ADMINPWD{
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_password"))
                    return
                }
                
                
                let pwdUint8 = Util.StringtoUINT8(data: newPWD, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
                
                
                
                let cmd = Config.bpProtocol.setUserPWD(UserIndex: self.userIndex, Password: pwdUint8)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                
                UserInfoTableViewController.tmpCMD = cmd
                
                for j in 0 ... cmd.count - 1{
                    
                    print(String(format:"%02x ",cmd[j]))
                }
                
            }else{
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("wrong format!"))
            } })
        
        
    }
    
    func didTapCard() {
        
        
        
        showEditCardDialog(Title: self.GetSimpleLocalizedString("users_card_edit_dialog_title"), CardValue: cardTextField.text!)
        
        
        
        
        
    }
    
    
    override func cmdAnalysis(cmd:[UInt8]){
        
        
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        
        if datalen == Int16(cmd.count - 4) {
            
            switch cmd[0] {
                
            case BPprotocol.cmd_set_user_id:
                
                if cmd[4] == BPprotocol.result_success{
                    print("count =%d \(UserInfoTableViewController.tmpCMD.count)")
                    let cmdData = Array(UserInfoTableViewController.tmpCMD[7...UserInfoTableViewController.tmpCMD.count-1])
                    var userIDArray = [UInt8]()
                    for j in 0 ... BPprotocol.userID_maxLen - 1{
                        print(String(format:"%02x",cmdData[j]))
                        
                        if cmdData[j] != 0xFF && cmdData[j] != 0x00{
                            userIDArray.append(cmdData[j])
                        }
                    }
                    let userId = String(bytes: userIDArray, encoding: .utf8) ?? "No Name"
                    
                    Config.userListArr[selectUser]["name"] = userId
                    
                    accountTextField.text = userId
                    
                    
                    //self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
                }else{
                    UserInfoTableViewController.tmpCMD.removeAll()
                    
                    //self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                    
                }
                break
                
            case BPprotocol.cmd_set_user_pwd:
                
                if cmd[4] == BPprotocol.result_success{
                    let cmdData = Array(UserInfoTableViewController.tmpCMD[7...UserInfoTableViewController.tmpCMD.count-1])
                    var pwdArray = [UInt8]()
                    for j in 0 ... BPprotocol.userPD_maxLen - 1{
                        print(String(format:"%02x",cmdData[j]))
                        if cmdData[j] != 0xFF && cmdData[j] != 0x00{
                            pwdArray.append(cmdData[j])
                        }
                    }
                    let pwdStr = String(bytes: pwdArray, encoding: .ascii) ?? ""
                    print("user pwd \(pwdStr)")
                    
                    
                    Config.userListArr[selectUser]["pw"] = pwdStr
                    
                    passwordTextField.text = pwdStr
                    
                    //self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
                    
                    
                    
                }else{
                    UserInfoTableViewController.tmpCMD.removeAll()
                    
                    // self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                }
                
                break
            case BPprotocol.cmd_set_user_card:
                
                if cmd[4] == BPprotocol.result_success{
                    let cmdData = Array(UserInfoTableViewController.tmpCMD[7...UserInfoTableViewController.tmpCMD.count-1])
                    
                    let cardStr = Util.UINT8toStringDecForCard(data: cmdData, len: 4)
                    print("user card \(cardStr)")
                    
                    
                    Config.userListArr[selectUser]["card"] =  cardStr
                    
                    cardTextField.text = cardStr
                    
                    
                    
                    
                    
                }else{
                    UserInfoTableViewController.tmpCMD.removeAll()
                    
                    
                }
                
                break
            case BPprotocol.cmd_user_del:
                if  cmd[4] == BPprotocol.result_success{
                    
                    Config.userListArr.remove(at: self.selectUser)
                    
                    _ = self.navigationController?.popViewController(animated: true)
                } else{
                    // self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                }
                break
                
            case BPprotocol.cmd_user_property:
                if cmd[1] == BPprotocol.type_read {
                    
                    var data = [UInt8]()
                    for i in 4 ... cmd.count - 1{
                        data.append(cmd[i])
                    }
                    for i in 0 ... data.count - 1{
                        
                        print(String(format:"R-data[%d]=%02x",(i), data[i]))
                    }
                    updateUserProperty(propertyData: data)
                    
                }else{
                    if cmd[4] == BPprotocol.result_success{
                        var data = [UInt8]()
                        print(String(format:"tmpbuff len=%d\r\n",UserInfoTableViewController.tmpCMD.count))
                        
                        for i in 7 ... UserInfoTableViewController.tmpCMD.count - 1{
                            data.append(UserInfoTableViewController.tmpCMD[i])
                            print(String(format:"wP-data[%d]=%02x",(i - 7), data[i-7]))
                        }
                        
                        updateUserProperty(propertyData: data)
                        
                        //  self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
                        UserInfoTableViewController.tmpCMD.removeAll()
                    }else{
                        
                        
                        //  self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                        UserInfoTableViewController.tmpCMD.removeAll()
                    }
                }
                break
                
            default:
                break
            }
        }
    }
    
    func updateUserProperty(propertyData:[UInt8]){
        
        if propertyData[0] & BPprotocol.enable_phone == BPprotocol.enable_phone{
            
            phoneSwitch.setOn(true, animated: true)
            
        }else{
            phoneSwitch.setOn(false, animated: true)
            
            
        }
        
        if propertyData[0] & BPprotocol.enable_card == BPprotocol.enable_card{
            
            cardSwitch.setOn(true, animated: true)
            
        }else{
            
            cardSwitch.setOn(false, animated: true)
            
        }
        
        if propertyData[0] & BPprotocol.enable_keypad == BPprotocol.enable_keypad{
            
            keypadSwitch.setOn(true, animated: true)
            
        }else{
            
            keypadSwitch.setOn(false, animated: true)
            
        }
        isEnableStatus = propertyData[0]
        
        print(String(format:"keypad=%02x", isEnableStatus))
        
        limitType = propertyData[1]
        print(String(format:"limitType=%02x",propertyData[1]))
        
        label_accessLimit.text = Config.accessTypesArray[Int(limitType)]
        
        var startTime = Array(propertyData[2...8])
        var isFirstSetupUser = 0
        for i in 0 ... startTime.count - 1 {
            if startTime[i] == 0x00{
                isFirstSetupUser += 1
            }
            
            print(String(format:"s time[%d]=%02x",i,startTime[i]))
        }
        
        
        var endTime = Array(propertyData[9...15])
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        if isFirstSetupUser == 7{
            
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            let sec = calendar.component(.second, from: date)
            
            startTime[0] = UInt8(year >> 8)
            startTime[1] = UInt8(year & 0x00FF)
            startTime[2] = UInt8(month)
            startTime[3] = UInt8(day)
            startTime[4] = UInt8(hour)
            startTime[5] = UInt8(minutes)
            startTime[6] = UInt8(sec)
            for i in 0 ... endTime.count - 1{
                endTime[i] = startTime[i]
            }
        }
        for i in 0 ... endTime.count - 1{
            print(String(format:"e time[%d]=%02x",i,endTime[i]))
        }
        
        openTimes = Int(propertyData[16])
        print(String(format:"time=%02x",propertyData[16]))
        
        weekly = propertyData[17]
        print(String(format:"weekly=%02x",propertyData[17]))
        
        startTimeArr = [Int(UInt16(startTime[0]) * 256 + UInt16(startTime[1])), Int(startTime[2]), Int(startTime[3]), Int(startTime[4]), Int(startTime[5]), Int(startTime[6])]
        
        endTimeArr = [Int(UInt16(endTime[0]) * 256 + UInt16(endTime[1])), Int(endTime[2]), Int(endTime[3]), Int(endTime[4]), Int(endTime[5]), Int(endTime[6])]
        if startTimeArr[0] < year{
            startTimeArr[0] = year
        }
        
        if endTimeArr[0] < year{
            endTimeArr[0] = year
        }
        updateFooterAccessTypeText()
        
        /*
         newStartTimeArr = startTimeArr
         newEndTimeArr = endTimeArr
         
         
         dayNtimeView.frame = UIScreen.main.bounds
         weeklyView.frame = UIScreen.main.bounds
         
         datePicker.datePickerMode = .date
         timePicker.datePickerMode = .time
         datePicker.date = Date()
         timePicker.minuteInterval = 1
         
         datePicker.minimumDate = Date()
         formatter.dateFormat = "yyyy/MM/dd"
         timeFormatter.dateFormat = "HH:mm"
         datePicker.maximumDate = formatter.date(from: "2036/12/31")
         
         datePicker.addTarget(self, action: #selector(EditUserViewController.didSelectDate), for: .valueChanged)
         timePicker.addTarget(self, action: #selector(EditUserViewController.didSelectTime), for: .valueChanged)
         
         weekStartTimeField.addTarget(self, action: #selector(EditUserViewController.beginEdit), for: .editingDidBegin)
         weekEndTimeField.addTarget(self, action: #selector(EditUserViewController.beginEdit), for: .editingDidBegin)
         
         startDateField.inputView = datePicker
         startTimeField.inputView = timePicker
         endDateField.inputView = datePicker
         endTimeField.inputView = timePicker
         
         startDateField.text = "\(startTimeArr[0])/\(String(format: "%02d",startTimeArr[1]) )/\(String(format: "%02d",startTimeArr[2]) )"
         startTimeField.text =  String(format: "%02d",startTimeArr[3]) + ":" + String(format: "%02d",startTimeArr[4])
         endDateField.text = "\(endTimeArr[0])/\(String(format: "%02d",endTimeArr[1]))/\(String(format: "%02d",endTimeArr[2]))"
         endTimeField.text = String(format: "%02d",endTimeArr[3]) + ":" + String(format: "%02d",endTimeArr[4])
         
         weekStartTimeField.text = String(format: "%02d",startTimeArr[3]) + ":" +  String(format: "%02d",startTimeArr[4])
         weekEndTimeField.text = String(format: "%02d",endTimeArr[3]) + ":" + String(format: "%02d",endTimeArr[4])
         weekStartTimeField.inputView = timePicker
         weekEndTimeField.inputView = timePicker
         mainTable.reloadData()*/
        
    }
    
    func updateFooterAccessTypeText(){
        let StartTimeArr = startTimeArr
        
        let EndTimeArr = endTimeArr
        
        switch limitType
        {
        case 0x00://.Permanent:
            
            UserInfoTableViewController.titleForFooter = ""
            
        case 0x01://.Schedule:
            
            
            let startTimerStr =  "\(String(format: "%04d",(StartTimeArr?[0])!))/\(String(format: "%02d",(StartTimeArr?[1])!))/\(String(format: "%02d",(StartTimeArr?[2])!))" + " " + String(format: "%02d",(StartTimeArr?[3])!) + ":" + String(format: "%02d",(startTimeArr?[4])!)
            
            let endTimerStr =  "\(String(format: "%04d",(EndTimeArr?[0])!))/\(String(format: "%02d",(EndTimeArr?[1])!))/\(String(format: "%02d",(EndTimeArr?[2])!))" + " " + String(format: "%02d",(EndTimeArr?[3])!) + ":" + String(format: "%02d",(EndTimeArr?[4])!)
            
            UserInfoTableViewController.titleForFooter =  startTimerStr + "~" + endTimerStr + "\n"
            
        case 0x02://.AccessTimes:
            UserInfoTableViewController.titleForFooter = GetSimpleLocalizedString("users_edit_access_control_dialog_type_times_mark") + "\((String(format:"%d",openTimes)))" + "\n"
            
        case 0x03://.Recurrent:
            let weekString = [GetSimpleLocalizedString("weekly_Sun"), GetSimpleLocalizedString("weekly_Mon"), GetSimpleLocalizedString("weekly_Tue"), GetSimpleLocalizedString("weekly_Wed"), GetSimpleLocalizedString("weekly_Thu"), GetSimpleLocalizedString("weekly_Fri"), GetSimpleLocalizedString("weekly_Sat")]
            var weekText = ""
            print(String(format:"%02x",weekly))
            for n: UInt8 in 0...6{
                
                if (weekly & (0x1 << n)) != 0{
                    weekText += weekString[Int(n)]
                }
            }
            
            let startTimerStr =  String(format: "%02d",(StartTimeArr?[3])!) + ":" + String(format: "%02d",(StartTimeArr?[4])!)
            
            let endTimerStr = String(format: "%02d",(EndTimeArr?[3])!) + ":" + String(format: "%02d",(EndTimeArr?[4])!)
            
            
            UserInfoTableViewController.titleForFooter =  weekText + "\n" + startTimerStr + " ~ " + endTimerStr
        default:
            UserInfoTableViewController.titleForFooter = ""
        }
        tableView.reloadData()
    }
    func showEditCardDialog(Title:String, CardValue:String) {
        
        
        //Set Initial Value
        EditCardDialogTitle.text = Title
        //        CardDialogConfirmBtn.titleLabel?.text = GetSimpleLocalizedString("Confirm")
        //        CardDialogCancelBtn.titleLabel?.text = GetSimpleLocalizedString("Cancel")
        
        CardDialogFrame.frame = CGRect(origin: CGPoint(x:0 ,y:0), size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        CardDialogView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        
        UIApplication.shared.keyWindow?.addSubview(self.CardDialogFrame)
        
        let CardInputs = [ CardInput1,CardInput2,
                           CardInput3, CardInput4,
                           CardInput5,CardInput6,
                           CardInput7,CardInput8,
                           CardInput9, CardInput10]
        
        
        for i in 0 ... CardInputs.count - 1{
            
            
            if CardValue != BPprotocol.spaceCardStr{
                let start = CardValue.index(CardValue.startIndex, offsetBy: i)
                let end = CardValue.index(CardValue.startIndex, offsetBy: i+1)
                let range = start..<end
                CardInputs[i]?.text = CardValue.substring(with: range)
                
            }else{
                CardInputs[i]?.text = " "
            }
            
            CardInputs[i]?.keyboardType = .numberPad
            CardInputs[i]?.delegate = self
            CardInputs[i]?.tag = 200
            CardInputs[i]?.addTarget(self, action: #selector(self.CardEditChange(field:)), for: UIControlEvents.editingChanged)
            
        }
        CardInputs[0]?.becomeFirstResponder()
        
        
        
    }
    
    func CardEditChange(field: UITextField){
        var cardNum = 0
        let CardInputs = [ CardInput1,CardInput2,
                           CardInput3, CardInput4,
                           CardInput5,CardInput6,
                           CardInput7,CardInput8,
                           CardInput9, CardInput10]
        
        
        if ( (field.text?.characters.count)! > 1 ) {
            
            let start = field.text?.index(after:(field.text?.startIndex)! )
            let end = field.text?.endIndex
            let range = start..<end
            field.text = field.text?.substring(with: range)
            
            field.text = field.text?.replacingOccurrences(of: "٠", with: "0", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "١", with: "1", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٢", with: "2", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٣", with: "3", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٤", with: "4", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٥", with: "5", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٦", with: "6", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٧", with: "7", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٨", with: "8", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "٩", with: "9", options: .literal, range: nil)
            
            field.text = field.text?.replacingOccurrences(of: "۰", with: "0", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۱", with: "1", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۲", with: "2", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۳", with: "3", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۴", with: "4", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۵", with: "5", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۶", with: "6", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۷", with: "7", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۸", with: "8", options: .literal, range: nil)
            field.text = field.text?.replacingOccurrences(of: "۹", with: "9", options: .literal, range: nil)
        }
        for i in 0 ... CardInputs.count - 1{
            if CardInputs[i]?.text != " "{
                cardNum +=   (CardInputs[i]?.text?.characters.count)!
                
            }
        }
        
        for i in 0 ... CardInputs.count - 1{
            if (CardInputs[i]?.text?.characters.count==1 && (CardInputs[i]?.isEditing)! ){
                
                if(i < (CardInputs.count - 1)){
                    CardInputs[i+1]?.becomeFirstResponder()
                    
                }else{
                    CardInputs[i]?.resignFirstResponder()
                    
                }
                break
            }
            
        }
        
        if (cardNum != 0 && cardNum != 10){
            CardDialogConfirmBtn.isEnabled = false
        }else{
            
            CardDialogConfirmBtn.isEnabled = true
        }
        
        
    }
    /*check backspace*/
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {   if textField.tag == 200{
        let CardInputs = [ CardInput1,CardInput2,
                           CardInput3, CardInput4,
                           CardInput5,CardInput6,
                           CardInput7,CardInput8,
                           CardInput9, CardInput10]
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        
        var cardNum = 0
        if (isBackSpace == -92) {
            
            
            for i in 0 ... CardInputs.count - 1{
                
                
                if(CardInputs[i]?.text?.characters.count==1 && (CardInputs[i]?.isEditing)! && (i != 0)){
                    CardInputs[i]?.text = " "
                    CardInputs[i-1]?.becomeFirstResponder()
                    
                }else if ((i == 0) && (CardInputs[i]?.isEditing)!){
                    CardInputs[i]?.text = " "
                    
                }
                
            }
            
            for i in 0 ... CardInputs.count - 1{
                if CardInputs[i]?.text != " "{
                    cardNum += (CardInputs[i]?.text?.characters.count)!
                }
                
            }
            if (cardNum != 0 && cardNum != 10){
                CardDialogConfirmBtn.isEnabled = false
            }else{
                
                CardDialogConfirmBtn.isEnabled = true
            }
            return false
        }
        
        
        
        }
        return true
    }
    override func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.CardDialogFrame.removeFromSuperview()
        
        
        
        if(displayAlerDialog != nil){
            displayAlerDialog?.dismiss(animated: true, completion: nil)
            
        }
        backToMainPage()
        
    }
}
