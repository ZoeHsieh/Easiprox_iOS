//
//  Intro_PasswordViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/7.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import ChameleonFramework
import IQKeyboardManagerSwift
import CoreBluetooth

enum RegisteredStatus {
    case Registered
    case NotRegistered
}

class Intro_PasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var passwordTopLayoutConstraint: NSLayoutConstraint!
    var registeredStatus: RegisteredStatus = .NotRegistered
    var selectedDevice:CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
        //passwordTextField.becomeFirstResponder()
        //passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(TextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        nextButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        deviceNameLabel.text = selectedDevice.name
        helloLabel.text = "Enroll User"
        accountTextField.becomeFirstResponder()
        accountTextField.isHidden = false
        accountTextField.isUserInteractionEnabled = true
        accountTextField.addTarget(self, action: #selector(TextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        passwordTopLayoutConstraint.constant = 8
        noteLabel.text = "if you forgot your ID or password, please contact your administrator"//"密碼請參閱說明書"
        registeredStatus = .NotRegistered
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
    
    @IBAction func didTapRegistered(_ sender: Any) {
        
        helloLabel.text = "Hello!"
        accountTextField.isHidden = true
        accountTextField.isUserInteractionEnabled = false
        passwordTopLayoutConstraint.constant = -29
        noteLabel.text = "if you forgot your ID or password, please contact your administrator"
        registeredStatus = .Registered
    }
    
    @IBAction func didTapNotRegistered(_ sender: Any) {
        
        helloLabel.text = "Enroll User"
        accountTextField.isHidden = false
        accountTextField.isUserInteractionEnabled = true
        passwordTopLayoutConstraint.constant = 8
        noteLabel.text = "if you forgot your ID or password, please contact your administrator"//"密碼請參閱說明書"
        registeredStatus = .NotRegistered
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func TextFieldDidChange(field: UITextField){
        
        
        if field == accountTextField{
            print("accountText field ")
            if( (field.text?.utf8.count)! > 16 ){
                field.deleteBackward();
            }
        }
         else if field == passwordTextField{
         if ( (field.text?.characters.count)! > 8 ) {
             field.deleteBackward();
         }
         
         }
        
        
        /* let countOfWords = string.characters.count +  textField.text!.characters.count - range.length*/
        
        if ((accountTextField.text?.characters.count)! >= 1) && ((passwordTextField.text?.characters.count)! >= 4)
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

}
