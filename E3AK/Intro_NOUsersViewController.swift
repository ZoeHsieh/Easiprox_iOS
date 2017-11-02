//
//  Intro_NOUsersViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/14.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class Intro_NOUsersViewController: UIViewController {

    @IBOutlet weak var noUsersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noUsersLabel.text = GetSimpleLocalizedString("There's no users, add now?")
        
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
