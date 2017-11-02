//
//  UserSetttingsTableViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/8/15.
//  Copyright © 2017年 BluePacket. All rights reserved.
//


import UIKit
import UIAlertController_Blocks
import CoreBluetooth


class UserSettingsTableViewController: BLE_tableViewController {
    
    
    @IBOutlet weak var deviceNameTitle: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    
    @IBOutlet weak var rssiTitle: UILabel!
    
    @IBOutlet weak var rssiLabel: UILabel!
    
  
    
    @IBOutlet weak var aboutTitle: UILabel!
    
    
    

    var selectedDevice:DeviceInfo!

    var tmpDeviceName:String?
    var current_level_RSSI:Int = 0
    
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBAction func backPageListener(_ sender: Any) {
        
        
            backToMainPage()
            
            
            
               
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = GetSimpleLocalizedString("Settings")
        
        deviceNameTitle.text = GetSimpleLocalizedString("Device Name")
        deviceNameLabel.text = selectedDevice.name
       
        rssiTitle.text = GetSimpleLocalizedString("Proximity Read Range")
        
       
        aboutTitle.text = GetSimpleLocalizedString("About Us")
        
     
        
      
        
       
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        rssiLabel.text = String(format:"%d",readExpectLevelFromDbByUUID(selectedDevice.peripheral.identifier.uuidString))
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView .deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row
        {
       
            
        case 1:
            let vc = ProximityReadRangeViewController(nib: R.nib.proximityReadRangeViewController)
            vc.selectedDevice = selectedDevice.peripheral
            vc.current_level_RSSI = current_level_RSSI
            navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            let vc = AboutUsViewController(nib: R.nib.aboutUsViewController)
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    
        
    
}


