//
//  RepeatDateViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/16.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class RepeatDateViewController: BLE_ViewController{

    @IBOutlet weak var tableView: UITableView!
   
    var selectedDateArray = [Bool](repeating: false, count: 7)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(String(format:"weekly=%02x]\r\n",AccessTypesViewController.weekly))
        
        for n: UInt8 in 0...6{
            if (AccessTypesViewController.weekly & (0x1 << n)) != 0{
                 selectedDateArray[Int(n)] = true
            }else{
                selectedDateArray[Int(n)] = false
            }
        }

        title = GetSimpleLocalizedString("Repeat Select")
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

extension RepeatDateViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Config.weekArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = Config.weekArr[indexPath.row]
        cell.imageView?.image = selectedDateArray[indexPath.row] ? R.image.tickGreen() : R.image.tickWhiteS()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDateArray[indexPath.row] = !selectedDateArray[indexPath.row]
        print(String(format:"row=%d\r\n",UInt8(indexPath.row)))
        var n = UInt8(indexPath.row)
        n = (0x1 << n)
        if selectedDateArray[indexPath.row]{
           
          AccessTypesViewController.weekly? += n
            
        }else{
          AccessTypesViewController.weekly? -= n
            
        }
        UserInfoTableViewController.tmpCMD[24] = AccessTypesViewController.weekly
        print(String(format:"weekly=%02x\r\n",AccessTypesViewController.weekly))
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
