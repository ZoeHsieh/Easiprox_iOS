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
