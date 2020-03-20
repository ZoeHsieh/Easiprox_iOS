//
//  AboutUsViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/21.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class AboutUsViewController: BLE_ViewController,MFMailComposeViewControllerDelegate,SFSafariViewControllerDelegate {

    @IBOutlet weak var appversionButton: UIButton!
    
    @IBOutlet weak var DeviceModelTitle: UILabel!
    @IBOutlet weak var deviceModelName: UILabel!
    
    //@IBOutlet weak var DeviceModelValue: UILabel!
    
    var deviceModel:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        title = GetSimpleLocalizedString("About Us")
//        DeviceModelTitle.text = GetSimpleLocalizedString("Device Model")
//        deviceModelName.text = "Easiprox⁺\nEasiprox⁺ Slim\nDG-800⁺\nDG-160⁺"
        
        let version : String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        
        appversionButton.setTitle(GetSimpleLocalizedString("APP version") + version, for: .normal)
    }
    
    @IBAction func open_URL(_ sender: UIButton) {
        goToURL()
    }
    @IBAction func send_Mail(_ sender: UIButton) {
        sendMail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

    func goToURL() {
            if let url = URL(string: "http://www.gianni.com.tw/") {
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            present(safari, animated: true, completion: nil)}
        }
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["inquiry1@gianni.com.tw"])
            mail.setSubject("Send from Easiprox APP")
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true)
        }
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
