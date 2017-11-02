//
//  DoorLockActionViewController.swift
//  E3AK
//
//  Created by BluePacket 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework

enum DoorLockAction: Int {
    case Use_Re_lock_Time = 0
    case Always_Unlocked = 1
    case Always_Locked = 2
}

class DoorLockActionViewController: BLE_ViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex: DoorLockAction?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format:"%02x",SettingsTableViewController.tmpConfig[6]))
        selectedIndex = DoorLockAction(rawValue: Int(SettingsTableViewController.tmpConfig[6]))
        
        title = GetSimpleLocalizedString("Door Lock Action")
        SettingsTableViewController.settingStatus = settingStatesCase.config_device.rawValue
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

extension DoorLockActionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Config.doorActionItem.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return GetSimpleLocalizedString("Please choose")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.tintColor = HexColor("00b900")
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(Config.doorActionItem[indexPath.row])"
        
        if indexPath.row == selectedIndex?.rawValue
        {
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (selectedIndex != nil)
        {
            if let unSelectedCell = tableView.cellForRow(at: IndexPath(row: (selectedIndex?.rawValue)!, section: 0))
            {
                unSelectedCell.accessoryType = .none
            }
        }
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        selectedIndex = DoorLockAction(rawValue: indexPath.row)
        var data = SettingsTableViewController.tmpConfig
        let delayTime = Int16((data[7])) * 256 + Int16((data[8]))
        data[6] = UInt8(indexPath.row)
        SettingsTableViewController.tmpConfig = Config.bpProtocol.setDeviceConfig(door_option: (data[5]), lockType: (data[6]), delayTime: delayTime, G_sensor_option: (data[9]))
        SettingsTableViewController.settingStatus = settingStatesCase.config_device.rawValue
        
    }
}
