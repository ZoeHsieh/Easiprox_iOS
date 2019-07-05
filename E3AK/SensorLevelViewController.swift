//
//  DoorLockActionViewController.swift
//  E5AR
//
//  Created by BluePacket 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework


class SensorLevelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format:"%02x",SettingsTableViewController.tmpSensorLevel))
        selectedIndex = Int(SettingsTableViewController.tmpSensorLevel - 1)
        
        title = GetSimpleLocalizedString("Tamper Sensor Level")
        SettingsTableViewController.settingStatus = settingStatesCase.sensor_level.rawValue
        
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

extension SensorLevelViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Config.SensorLevelItem.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return GetSimpleLocalizedString("Please choose")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.tintColor = HexColor("00b900")
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(Config.SensorLevelItem[indexPath.row])"
        
        if indexPath.row == selectedIndex
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
            if let unSelectedCell = tableView.cellForRow(at: IndexPath(row: selectedIndex!, section: 0))
            {
                unSelectedCell.accessoryType = .none
            }
        }
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        selectedIndex =  indexPath.row
      
       
        SettingsTableViewController.tmpSensorLevel = UInt8(indexPath.row) + 1
        print("Level = \(SettingsTableViewController.tmpSensorLevel)")
        SettingsTableViewController.settingStatus = settingStatesCase.sensor_level.rawValue
    }
}

