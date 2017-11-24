//
//  UIViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/7.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import CoreBluetooth

extension UIViewController: StoryboardIdentifiable, UIActionSheetDelegate{
    

    public func openBlueTooth_Setting()->UIAlertController {
        let url = URL(string: "APP-Prefs:root=Bluetooth") //for Bluetooth Setting
        let app = UIApplication.shared
        
        let alertController = UIAlertController(title: "Enable the BlueTooth?", message: "Do You Enable the BlueTooth ?", preferredStyle: .alert)
        
        let cancelAct = UIAlertAction(title: GetSimpleLocalizedString("Cancel"), style: UIAlertActionStyle.cancel, handler: nil)
        
        let openBtAct = UIAlertAction(title: GetSimpleLocalizedString("Open"), style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            app.openURL(url!)
        }
        
        alertController.addAction(cancelAct);
        alertController.addAction(openBtAct);
        
        self.present(alertController, animated: true, completion: nil)
        
        return alertController
    }

    func setNavigationBarItemWithImage(imageName: String) {
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: (UIImage(named: imageName)), style: .plain, target: self, action: #selector(self.didTapItem))
        rightBarButtonItem.tintColor = HexColor("00B900")
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setNavigationBarRightItemWithTitle(title: String) {
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.didTapItem))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setNavigationBarSkipItem() {
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: GetSimpleLocalizedString("Skip"), style: .plain, target: self, action: #selector(self.didTapSkipItem))
        rightBarButtonItem.tintColor = HexColor("00B900")
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    public func didTapItem() {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    public func didTapSkipItem() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
//        guard let rootViewController = window.rootViewController else {
//            return
//        }
        Config.bleManager.disconnect()
        let storyboard = UIStoryboard(storyboard: .Main)
        let vc: HomeNavigationController = storyboard.instantiateViewController()
//        vc.view.frame = rootViewController.view.frame
//        vc.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: { completed in
            // maybe do something here
        })
    }
    func Convert_RSSI_to_LEVEL(_ rssi: Int) -> Int {
        var value: Int = (Config.BLE_RSSI_MAX - rssi) / Config.BLE_RSSI_LEVEL_CONVERT_BASE
        
        if (value > Config.BLE_RSSI_LEVEL_MAX) {
            value = Config.BLE_RSSI_LEVEL_MAX;
        }
        
        if (value < Config.BLE_RSSI_LEVEL_MIN) {
            value = Config.BLE_RSSI_LEVEL_MIN;
        }
        
        return value
    }
    
    func Convert_LEVEL_to_RSSI(_ level: Int) -> Int {
        return (level * (-1) * (
            Config.BLE_RSSI_LEVEL_CONVERT_BASE)) + Config.BLE_RSSI_MAX;
    }
    
    func saveExpectLevelToDbByUUID(_ uuidString: String, _ expect_level: Int) {
     
       //Save to DB
        Config.saveParam.setValue(expect_level, forKey: (uuidString + Config.RSSI_LEVEL_Tag))
        Config.saveParam.set(true, forKey: (uuidString + Config.RSSI_DB_EXIST))
        Config.saveParam.synchronize()
        
       
    }
    
    func readExpectLevelFromDbByUUID(_ uuidString: String) -> Int {
        
        //Get Expect Level from DB
        var expect_level: Int? = Config.saveParam.integer(forKey: (uuidString + Config.RSSI_LEVEL_Tag))
        let isDeviceExist: Bool = Config.saveParam.bool(forKey: (uuidString + Config.RSSI_DB_EXIST))
        
        if(!isDeviceExist) {
            //print("expect_level is nil ")
            
            expect_level = Config.BLE_RSSI_LEVEL_DEFAULT
        }
        
       // print("expect_level = \(expect_level)")
        
        return expect_level!
    }
    func delayOnMainQueue(delay: Double, closure: @escaping ()->()) {
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    func showToastDialog(title:String,message:String){
        
        
        let messageDailog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        delayOnMainQueue(delay: 1, closure: {
            messageDailog.dismiss(animated: true, completion: nil)
            
        })
        
        
        self.present(messageDailog, animated: true, completion: nil)
    }
    
    func GetSimpleLocalizedString(_ key: String) -> String {
        
        return NSLocalizedString(key, comment: "")
    }
    
    func backToMainPage(){
       
        delayOnMainQueue(delay: 0.5, closure: {
           
            for vc in (self.navigationController?.viewControllers ?? []){
              
               
                if (vc is HomeViewController){
                  
                    self.navigationController?.popToViewController(vc, animated: false)
                    
                }
                
            }
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }

    func alertWithTextField(title: String, subTitle: String, placeHolder: String, keyboard: UIKeyboardType, defaultValue: String,Tag:Int,handler: @escaping ((_ inputText: String?) -> Void))->UIAlertController{
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            var PlaceHolder = NSMutableAttributedString()
                        // Set the Font
            PlaceHolder = NSMutableAttributedString(string: placeHolder, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 15.0)!])
            
            // Set the color
            PlaceHolder.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range:NSRange(location:0,length:placeHolder.characters.count))
            
            // Add attribute        
            
            textField.attributedPlaceholder = PlaceHolder
            textField.keyboardType = keyboard
            textField.tag = Tag
            textField.text = defaultValue
            //textField.textColor = UIColor.gray
            textField.addTarget(self, action: #selector(self.editAlertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        })
        
        
        let confirmAction = UIAlertAction(title:GetSimpleLocalizedString("Confirm"), style: .default, handler: { action in
            if let inputText = alertController.textFields!.first?.text{
                print("user input: \(inputText)")
                handler(inputText)
            }
        })
        let cancelAction = UIAlertAction(title:GetSimpleLocalizedString("Cancel"), style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: 1.0,y :1.0), size: CGSize(width: self.view.bounds.size.width / 2.0, height: self.view.bounds.size.height / 2.0))
        self.present(alertController, animated: true, completion: nil)
        
        return alertController
    }
       
    func editAlertTextFieldDidChange(field: UITextField){
        let alertController: UIAlertController = self.presentedViewController as! UIAlertController
        let textField: UITextField = alertController.textFields![0];
        
        let addAction: UIAlertAction = alertController.actions[0];
        if textField.tag == 0{// for user id
            
            if ( (textField.text?.utf8.count)! > BPprotocol.userID_maxLen ) {
                textField.deleteBackward();
            }
            
            addAction.isEnabled = ((textField.text?.utf8.count)! >= 1 )
        }else if textField.tag == 1{ // for user pwd
            
            if ( (textField.text?.utf8.count)! > BPprotocol.userPD_maxLen ) {
                textField.deleteBackward();
            }
            addAction.isEnabled = ((textField.text?.characters.count)! >= 4 );
        }else if textField.tag == 2{ // for door delay time
            
            if ( (textField.text?.utf8.count)! > 4) {
                textField.deleteBackward();
            }
            if (textField.text?.utf8.count)! > 0{
                addAction.isEnabled = ((textField.text?.characters.count)! <= 4 ) &&  (Int16((textField.text!))! <= Config.DOOR_DELAY_TIME_LIMIT) &&  (Int16((textField.text!))! > 0)
            }else{
                addAction.isEnabled = false
            }
        }else if textField.tag == 3{ // for access times
            
            if ( (textField.text?.utf8.count)! > 3) {
                textField.deleteBackward();
            }
            if (textField.text?.utf8.count)! > 0{
                addAction.isEnabled = ((textField.text?.characters.count)! <= 3 ) && (Int(textField.text!)!<=255)
            }else{
                addAction.isEnabled = false
            }
        }else if textField.tag == 4{ // for user card
            
            if ( (textField.text?.utf8.count)! > BPprotocol.userCardID_maxLen ) {
                textField.deleteBackward();
            }
            addAction.isEnabled = ((textField.text?.utf8.count)! == BPprotocol.userCardID_maxLen ) ||  ((textField.text?.utf8.count)! == 0 );
        }
        
        //Check Length
        
        
    }
   
    func loginAlert(title: String, subTitle: String, placeHolder1: String, placeHolder2: String, keyboard1: UIKeyboardType, keyboard2: UIKeyboardType, handler: @escaping ((_ inputText1: String?, _ inputText2: String?) -> Void))->UIAlertController{
        
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeHolder1
            textField.keyboardType = keyboard1
            textField.tag = 0;
            textField.textColor = UIColor.black
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        })
       
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeHolder2
            textField.keyboardType = keyboard2
            textField.tag = 1;
            textField.textColor = UIColor.black
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        })
        
        let confirmAction = UIAlertAction(title: GetSimpleLocalizedString("Confirm"), style: .default, handler: { action in
            if let inputText1 = alertController.textFields!.first?.text, let inputText2 = alertController.textFields!.last?.text{
                print("user input: \(inputText1) & \(inputText2)")
                handler(inputText1, inputText2)
                
            }
        })
        
        let cancelAction = UIAlertAction(title:  GetSimpleLocalizedString("Cancel"), style: .cancel, handler: nil)
        
        confirmAction.isEnabled = false
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: 1.0,y :1.0), size: CGSize(width: self.view.bounds.size.width / 2.0, height: self.view.bounds.size.height / 2.0))
        self.present(alertController, animated: true, completion: nil)
        
        return alertController
    }
    

    func alertTextFieldDidChange(field: UITextField)->UIAlertController{
        let alertController: UIAlertController = self.presentedViewController as! UIAlertController
        let textField_id: UITextField = alertController.textFields![0];
        let textField_password: UITextField = alertController.textFields![1];
        let addAction: UIAlertAction = alertController.actions[0];
        
        //Check Length
        if ( (textField_id.text?.utf8.count)! > BPprotocol.userID_maxLen ) {
            textField_id.deleteBackward();
        }
        
        if ( (textField_password.text?.utf8.count)! > BPprotocol.userPD_maxLen  ) {
            textField_password.deleteBackward();
        }
        
        addAction.isEnabled = ((textField_id.text?.characters.count)! >= 1 ) && ((textField_password.text?.characters.count)! >= 4 )
        
        return alertController
    }

   
}
