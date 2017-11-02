//
//  Intro_AddMoreUserViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/14.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

class Intro_AddMoreUserViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let  accountArr = ["Chris"]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let footerView = R.nib.intro_AddMoreUserFooterView.firstView(owner: nil)
        footerView?.delegate = self
        tableView.tableFooterView = footerView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(R.nib.usersTableViewCell)
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
        return accountArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.usersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        cell.accountLabel.text = "\(accountArr[indexPath.row])"
        cell.disclosureImageView.isHidden = true
        //cell.deviceLabel.text = "\(deviceArr[indexPath.row])"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
