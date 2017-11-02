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
    var openTimes:Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        accessTimesTextField.placeholder =  NSLocalizedString("Please enter access times", comment: "")
        accessTimesTextField.addTarget(self, action: #selector(AccessTimesTableViewCell.checkLen), for: .editingChanged)
        accessTimesTextField.addTarget(self, action: #selector(AccessTimesTableViewCell.didEdit), for: .editingDidEnd)
        
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
    
      
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    func didEdit(){
        if((accessTimesTextField.text?.contains("(format error)"))!){
            accessTimesTextField.text = String(format:"%d",openTimes)
            
        }
        if (accessTimesTextField.text?.utf8.count)! > 0  {
            openTimes = Int(accessTimesTextField.text!)!
        }
    
        if !((accessTimesTextField.text?.utf8.count)! > 0
        && (Int(accessTimesTextField.text!)!<=255)) {
            
           
        
            accessTimesTextField.text = accessTimesTextField.text! + NSLocalizedString("(format error)", comment: "")
            accessTimesTextField.textColor = UIColor.red
            
        }else{
            accessTimesTextField.textColor = UIColor.darkGray
                UserInfoTableViewController.tmpCMD[8] = 0x02
             UserInfoTableViewController.tmpCMD[23] = UInt8(accessTimesTextField.text!)!
            AccessTypesViewController.openTimes = Int(accessTimesTextField.text!)!
           
        }
    
    
    
    }
    
    
    func checkLen(){
        if ( ( accessTimesTextField.text?.utf8.count)! > 3) {
             accessTimesTextField.deleteBackward();
        }
        
     
    }
    
    
    
}
