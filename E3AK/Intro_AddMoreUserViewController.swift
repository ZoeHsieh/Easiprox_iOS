//
//  Intro_AddMoreUserViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/14.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import CoreBluetooth

class Intro_AddMoreUserViewController: BLE_ViewController {

    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    var selectedDevice:CBPeripheral!
     var localUserArr:[[String:Any]] = []
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let footerView = R.nib.intro_AddMoreUserFooterView.firstView(owner: nil)
        footerView?.delegate = self
        tableView.tableFooterView = footerView
        
        IDLabel.text = self.GetSimpleLocalizedString("ID")
        passwordLabel.text = self.GetSimpleLocalizedString("Password")
        userLabel.text = self.GetSimpleLocalizedString("User Name")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(R.nib.usersTableViewCell)
        localUserArr = Config.userListArr
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        localUserArr = Config.userListArr
        tableView.reloadData()
       
        
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

extension Intro_AddMoreUserViewController: Intro_AddMoreUserFooterViewDelegate{
    
    func didTapAddMore() {
        
        let vc = parent as! Intro_UserViewController
        vc.showAddUserViewController()
    }
}

extension Intro_AddMoreUserViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Config.userListArr
.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.usersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        cell.setArrowHide(true)
        if localUserArr.count > indexPath.row {
            guard localUserArr[indexPath.row]["name"] != nil else{
                return cell
            }
            cell.accountLabel.text = "\(localUserArr[indexPath.row]["name"] as! String)"
            
            
            cell.passwordLabel.text = "\(localUserArr[indexPath.row]["pw"] as! String)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
