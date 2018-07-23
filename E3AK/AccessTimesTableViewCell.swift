//
//  AccessTimesTableViewCell.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/16.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class AccessTimesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var accessTimesTextField: UITextField!
    var ViewController: UIViewController?
    var openTimes:Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        accessTimesTextField.placeholder =  NSLocalizedString("Please enter access times", comment: "")
        accessTimesTextField.addTarget(self, action: #selector(AccessTimesTableViewCell.didEdit), for: .editingChanged)
        
        
    }

    func setTimesValue(times:Int){
    
       
        if times > 255 {
            
            
             accessTimesTextField.text = String(format:"%d",times)
            accessTimesTextField.text = accessTimesTextField.text! + NSLocalizedString("(format error)", comment: "")
            accessTimesTextField.textColor = UIColor.red
            openTimes = times
        }else{
             accessTimesTextField.text = String(format:"%d",times)
            accessTimesTextField.textColor = UIColor.darkGray

        }
    }
    
    func setViewController(controller:UIViewController){
        ViewController = controller
    }
      
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    func didEdit(){
        
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٠", with: "0", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "١", with: "1", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٢", with: "2", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٣", with: "3", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٤", with: "4", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٥", with: "5", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٦", with: "6", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٧", with: "7", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٨", with: "8", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٩", with: "9", options: .literal, range: nil)
        
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۰", with: "0", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۱", with: "1", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۲", with: "2", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۳", with: "3", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۴", with: "4", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۵", with: "5", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۶", with: "6", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۷", with: "7", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۸", with: "8", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۹", with: "9", options: .literal, range: nil)
        
        if ( ( accessTimesTextField.text?.utf8.count)! > 3) {
            accessTimesTextField.deleteBackward();
        }
        
        if accessTimesTextField.text != ""{
            
           
        
          if !((accessTimesTextField.text?.utf8.count)! > 0
          && (Int(accessTimesTextField.text!)!<=255)) {
            
            ViewController?.showToastDialog(title: "", message: (ViewController?.GetSimpleLocalizedString("over_range_alarm"))!)
            
          }else{
            accessTimesTextField.textColor = UIColor.darkGray
            
                UserInfoTableViewController.tmpCMD[8] = 0x02
             UserInfoTableViewController.tmpCMD[23] = UInt8(accessTimesTextField.text!)!
            
            AccessTypesViewController.openTimes = Int(accessTimesTextField.text!)!
           
           }
       }
        
    
    }
    
    
  
    
    
    
}
