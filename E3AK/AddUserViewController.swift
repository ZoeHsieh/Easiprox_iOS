//
//  AddUserViewController.swift
//  E5AKR
//
//  Created by BluePacket on 2017/6/14.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreBluetooth

protocol AddUserViewControllerDelegate {
    func didTapAdd(result:Bool)
}

class AddUserViewController: BLE_ViewController, UITextFieldDelegate{

    public var delegate: AddUserViewControllerDelegate?
    @IBOutlet weak var accountTitle: UILabel!
    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var cardTitle: UILabel!
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
    @IBOutlet weak var EditCardUI: UIStackView!
    @IBOutlet weak var EditCardBG: UITextField!
    var tmpID:String = ""
    var tmpPassword:String = ""
    var tmpCard:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        title = GetSimpleLocalizedString("Add Users")
        configUI()
        accountTitle.text = GetSimpleLocalizedString("ID")
        accountTextField.placeholder = GetSimpleLocalizedString("Please Provide Up to 16 characters")
        passwordTitle.text = GetSimpleLocalizedString("Password/PIN Code")
        passwordTextField.placeholder = GetSimpleLocalizedString("4~8 digits")
        cardTitle.text = GetSimpleLocalizedString("Card")
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        accountTextField.tag = 0
        accountTextField.addTarget(self, action: #selector(self.userAddTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        
        passwordTextField.tag = 1
        passwordTextField.addTarget(self, action: #selector(self.userAddTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
        passwordTextField.keyboardType = .numberPad
        EditCardBG.isUserInteractionEnabled  = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        if Config.deviceType == Config.deviceType_Keypad{
            EditCardUI.isHidden = true
            cardTitle.isHidden = true
            EditCardBG.isHidden = true
        }
        
        let CardInputs = [ CardInput1,CardInput2,
                           CardInput3, CardInput4,
                           CardInput5,CardInput6,
                           CardInput7,CardInput8,
                           CardInput9, CardInput10]
        
        
        for i in 0 ... CardInputs.count - 1{
            
            CardInputs[i]?.text = " "
            CardInputs[i]?.keyboardType = .numberPad
            CardInputs[i]?.delegate = self
            CardInputs[i]?.tag = 200
            CardInputs[i]?.addTarget(self, action: #selector(self.userAddTextFieldDidChange(field:)), for: UIControl.Event.editingChanged)
            
        }
        //        CardInputs[0]?.becomeFirstResponder()
        
        
        
    
    
    }

    














    func configUI() {
        
        setNavigationBarRightItemWithTitle(title: self.GetSimpleLocalizedString("Add"))
        let leftBtn = UIButton(type: .custom)
        leftBtn.setTitle(self.GetSimpleLocalizedString("Cancel"), for: .normal)
        leftBtn.setTitleColor(UIColor.flatGreen(), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        leftBtn.addTarget(self, action: #selector(didTapLeftBarButtonItem), for: .touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        accountTextField.setTextFieldPaddingView()
        accountTextField.setTextFieldBorder()
        
        passwordTextField.setTextFieldPaddingView()
        passwordTextField.setTextFieldBorder()
        
        
    }
    
    override func cmdAnalysis(cmd:[UInt8]){
        
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        for i in 0 ... cmd.count - 1{
            print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
        }
        if datalen == Int16(cmd.count - 4) {
            switch cmd[0]{
                
            case BPprotocol.cmd_user_add:
                UsersViewController.result_userAction = 0
                if datalen == 2{
                    
                    let userIndex = Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    print("tmp id2= \(tmpID)")
                    print("tmp pwd2= \(tmpPassword))")
                    
                    Config.userListArr.append(["pw": tmpPassword, "name":tmpID,"card":tmpCard,"index":userIndex])
                    
                    delegate?.didTapAdd(result: true)
                    
                }
                else{
                    UsersViewController.result_userAction = 1
                    
                    
                }
                UsersViewController.status = userViewStatesCase.userAction.rawValue
                dismiss(animated: true, completion: nil)
                break
            case BPprotocol.cmd_read_card:
                                        
                               var data = [UInt8]()
                                           
                               for i in 4 ... cmd.count - 1{
                                   data.append(cmd[i])
                               }
                                        
                               if(data.count == 4){
                                  var readCardValue = Util.UINT8toStringDecForCard(data: data, len: 4)
                                   if readCardValue.count != 10{ return }
                                           
                                           let CardInputs = [ CardInput1,CardInput2,
                                                                     CardInput3, CardInput4,
                                                                     CardInput5,CardInput6,
                                                                     CardInput7,CardInput8,
                                                                     CardInput9, CardInput10]
                                           let CardValue = readCardValue
                                           
                                           for i in 0 ... CardInputs.count - 1{
                                                
                                                    
                                                    if CardValue != BPprotocol.spaceCardStr{
                                                        let start = CardValue.index(CardValue.startIndex, offsetBy: i)
                                                        let end = CardValue.index(CardValue.startIndex, offsetBy: i+1)
                                                        let range = start..<end
                                                        CardInputs[i]?.text = CardValue.substring(with: range)
                                                        
                                                      }else{
                                                        CardInputs[i]?.text = " "
                                                   
                                                    }
                                                    
                                                  
                                               CardInputs[i]?.endEditing(true)
                                           }
                                           
                                           readCardValue = ""
                               }

                               break
                
            default:
                break
                
            }
        }
        
    }
    @objc func userAddTextFieldDidChange(field: UITextField){
        var cardNum = 0
        let CardInputs = [ CardInput1,CardInput2,
                           CardInput3, CardInput4,
                           CardInput5,CardInput6,
                           CardInput7,CardInput8,
                           CardInput9, CardInput10]
        
    
        
        
        if field.tag == 0{// for user id
            
            if ( (field.text?.utf8.count)! > BPprotocol.userID_maxLen ){
                field.deleteBackward();
            }
       
     
            
        }else if field.tag == 1{ // for user pwd
            
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
            
            
            
            if ( (field.text?.utf8.count)! > BPprotocol.userPD_maxLen ) {
                field.deleteBackward();
            }
            
            
            
            
         
        }else if field.tag == 200{ // for user card id
            
            
            if ( (field.text?.count)! > 1 ) {
                
                let start = field.text?.index(after:(field.text?.startIndex)! )
                let end = field.text?.endIndex
                //let range = start..<end
                //field.text = field.text?.substring(with: range)
                field.text =  String((field.text?[start!..<end!])!)
                
                
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
                    
                    //                    switch CardInputs[i]?.text {
                    //                    case "٠"?:
                    //                        CardInputs[i]?.text = "0"
                    //                    case "١"?:
                    //                        CardInputs[i]?.text = "1"
                    //                    case "٢"?:
                    //                        CardInputs[i]?.text = "2"
                    //                    case "٣"?:
                    //                        CardInputs[i]?.text = "3"
                    //                    case "٤"?:
                    //                        CardInputs[i]?.text = "4"
                    //                    case "٥"?:
                    //                        CardInputs[i]?.text = "5"
                    //                    case "٦"?:
                    //                        CardInputs[i]?.text = "6"
                    //                    case "٧"?:
                    //                        CardInputs[i]?.text = "7"
                    //                    case "٨"?:
                    //                        CardInputs[i]?.text = "8"
                    //                    case "٩"?:
                    //                        CardInputs[i]?.text = "9"
                    //
                    //
                    //
                    //
                    //                    case "۰"?:
                    //                        CardInputs[i]?.text = "0"
                    //                    case "۱"?:
                    //                        CardInputs[i]?.text = "1"
                    //                    case "۲"?:
                    //                        CardInputs[i]?.text = "2"
                    //                    case "۳"?:
                    //                        CardInputs[i]?.text = "3"
                    //                    case "۴"?:
                    //                        CardInputs[i]?.text = "4"
                    //                    case "۵"?:
                    //                        CardInputs[i]?.text = "5"
                    //                    case "۶"?:
                    //                        CardInputs[i]?.text = "6"
                    //                    case "۷"?:
                    //                        CardInputs[i]?.text = "7"
                    //                    case "۸"?:
                    //                        CardInputs[i]?.text = "8"
                    //                    case "۹"?:
                    //                        CardInputs[i]?.text = "9"
                    //
                    //
                    //
                    //                    default:
                    //                        print("")
                    //                    }
                    
                    
                    
                    cardNum +=   (CardInputs[i]?.text?.count)!
                    
                    if (CardInputs[i]?.text?.contains(" "))!{
                        cardNum -= 1
                    }
                    
                }
            }
            
            for i in 0 ... CardInputs.count - 1{
                if (CardInputs[i]?.text?.count==1 && (CardInputs[i]?.isEditing)! ){
                    
                    if(i < (CardInputs.count - 1)){
                        CardInputs[i+1]?.becomeFirstResponder()
                        
                    }else{
                        CardInputs[i]?.resignFirstResponder()
                        
                    }
                    break
                }
                
            }
            
            
        }
        
        if ((self.passwordTextField.text?.utf8.count)! >= 4) &&
            ((self.accountTextField.text?.utf8.count)! >= 1 ){
            
            self.navigationItem.rightBarButtonItem?.isEnabled = (cardNum == 0 ) || (cardNum == BPprotocol.userCardID_maxLen )
            print("cardNum= \(cardNum)\r\n")
            
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
        }
        
        
    }
    
    @objc func didTapLeftBarButtonItem() {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    override func didTapItem() {
        if !(accountTextField?.text?.isEmpty)! && !(passwordTextField?.text?.isEmpty)!{
            guard (passwordTextField?.text?.count)! > 3 && (passwordTextField?.text?.count)! < BPprotocol.userPD_maxLen+1 else{
                
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_pwd"))
                return
            }
            
            let nameArr = Config.userListArr.map{ $0["name"] as! String }
            let pwArr = Config.userListArr.map{ $0["pw"] as! String }
            let cardArr = Config.userListArr.map{ $0["card"] as! String}
            print("name size = \(nameArr.count)")
            if nameArr.contains((accountTextField?.text!)!){
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_name"))
                return
            }
            
            if (accountTextField?.text?.localizedUppercase)! == Config.AdminID || (accountTextField?.text?.localizedUppercase)! == "ADMIN"{
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_name"))
                return
            }
            
            
            if pwArr.contains((passwordTextField.text)!){
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_password"))
                return
                
            }
            if  passwordTextField.text == Config.ADMINPWD{
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_pwd"))
                return
                
            }
            
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
                    
                    cardNum +=   (CardInputs[i]?.text?.count)!
                    
                }
            }
            if newCard == "" && cardNum == 0{
                newCard = BPprotocol.spaceCardStr
            }
            
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
                
                if  newCard  == Config.ADMINCARD && newCard  != ""{
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_card"))
                    return
                    
                }
                
                let cardArr = Config.userListArr.map{ $0["card"] as! String }
                
                
                if cardArr.contains(newCard){
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_card"))
                    return
                }
                tmpCard = newCard
                
            }else{
                tmpCard = BPprotocol.spaceCardStr
            }
            
            
            
            tmpID = accountTextField.text!
            tmpPassword = passwordTextField.text!
            
            print("tmp id= \(tmpID)")
            print("tmp pwd= \(tmpPassword)")
            print("tmp card= \(tmpCard)")
            let userID:[UInt8] = Util.StringtoUINT8ForID(data: tmpID, len: BPprotocol.userID_maxLen, fillData: BPprotocol.nullData)
            
            let userPWD:[UInt8] = Util.StringtoUINT8(data: tmpPassword, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
            var cmdData = Data()
            if Config.deviceType != Config.deviceType_Keypad{
                
                
                if  cardNum == 10{
                    let userCard:[UInt8] = Util.StringDecToUINT8(data: tmpCard, len: BPprotocol.userCardID_maxLen)
                    
                    cmdData = Config.bpProtocol.setUserAdd(Password: userPWD, ID: userID, card:userCard)
                }else{
                    let cardData:[UInt8] = [0xFF,0xFF,0xFF,0xFF]
                    
                    cmdData = Config.bpProtocol.setUserAdd(Password: userPWD, ID: userID, card:cardData)
                }
                
            }else{
                
                cmdData = Config.bpProtocol.setUserAdd(Password: userPWD, ID: userID)
                
            }
            for i in 0 ... cmdData.count - 1 {
                print("cmd add=%02x",cmdData[i])
            }
            
            Config.bleManager.writeData(cmd: cmdData, characteristic: self.bpChar!)
            
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
                
                
                if(CardInputs[i]?.text?.count==1 && (CardInputs[i]?.isEditing)! && (i != 0)){
                    CardInputs[i]?.text = " "
                    CardInputs[i-1]?.becomeFirstResponder()
                    
                }else if ((i == 0) && (CardInputs[i]?.isEditing)!){
                    CardInputs[i]?.text = " "
                    
                }
                
            }
            
            for i in 0 ... CardInputs.count - 1{
                if CardInputs[i]?.text != " "{
                    cardNum += (CardInputs[i]?.text?.count)!
                }
                
            }
            if ((self.passwordTextField.text?.utf8.count)! >= 4) &&
                ((self.accountTextField.text?.utf8.count)! >= 1 ){
                
                print("cardNum= \(cardNum)\r\n")
                self.navigationItem.rightBarButtonItem?.isEnabled = (cardNum == 0 ) || (cardNum == BPprotocol.userCardID_maxLen )
                
            }else{
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                
            }
            return false
        }
        
        
        
        }
        return true
    }
    

    
}
