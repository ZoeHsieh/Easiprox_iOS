//
//  AboutUsViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/21.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class AboutUsViewController: BLE_ViewController {

    @IBOutlet weak var appversionButton: UIButton!
    
    @IBOutlet weak var DeviceModelTitle: UILabel!
    
    //@IBOutlet weak var DeviceModelValue: UILabel!
    
    var deviceModel:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = GetSimpleLocalizedString("About Us")
        DeviceModelTitle.text = GetSimpleLocalizedString("Device Model") + "E3AK"
        let version : String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        //DeviceModelValue.text = "E3AK"//deviceModel
        appversionButton.setTitle(GetSimpleLocalizedString("APP version") + version, for: .normal)
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

}
