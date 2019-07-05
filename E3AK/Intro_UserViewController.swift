//
//  Intro_UserViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreBluetooth

class Intro_UserViewController: BLE_ViewController {

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    var isNOUser = true
    var selectedDevice:CBPeripheral!

    @IBOutlet weak var deviceNameTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
        deviceNameTitle.text = selectedDevice.name
     rightButton.setTitle(GetSimpleLocalizedString("Skip"), for: .normal)
      nextButton.setTitle(GetSimpleLocalizedString("Add"), for: .normal)
      
        nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        add(asChildViewController: Intro_NOUsersViewController(nib: R.nib.intro_NOUsersViewController))
    }
    override func peripheral(_ peripheral: CBPeripheral,
                             didReadRSSI RSSI: NSNumber,
                             error: Error?) {
        let rssi = RSSI.intValue
        let vc = storyboard?.instantiateViewController(withIdentifier :"Intro_DistanceSettingsViewController") as! Intro_DistanceSettingsViewController
        
        vc.selectedDevice = selectedDevice
        vc.bpChar = self.bpChar
        navigationController?.pushViewController(vc, animated: true)
        
        print("rssi = \(rssi)")
        vc.rssiCurrentLevel = String(format:"%d",Convert_RSSI_to_LEVEL(rssi))
    }

    @IBAction func didTapNext(_ sender: Any) {
         Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        if isNOUser
        {
            showAddUserViewController()
        }else{
          
         selectedDevice.readRSSI()
          
        }
       
    }
    
    func showAddUserViewController() {
        let vc = AddUserViewController(nib: R.nib.addUserViewController)
        let navVC: UINavigationController = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        vc.bpChar = self.bpChar
        present(navVC, animated: true, completion: nil)
    }
    
    func showIntro_DistanceSettingsViewController() {
        let vc = R.storyboard.intro.intro_DistanceSettingsViewController()
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    func swapViewController(from: UIViewController, to: UIViewController) {
        
    }
    
    func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
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

extension Intro_UserViewController: AddUserViewControllerDelegate{
    
    func didTapAdd() {
    
        if isNOUser && UsersViewController.result_userAction == 0
        {
            
            nextButton.setTitle(GetSimpleLocalizedString("Next"), for: .normal)
            remove(asChildViewController: Intro_NOUsersViewController(nib: R.nib.intro_NOUsersViewController))
            add(asChildViewController: Intro_AddMoreUserViewController(nib: R.nib.intro_AddMoreUserViewController))
            let vc = Intro_AddMoreUserViewController(nib: R.nib.intro_AddMoreUserViewController)
            vc.selectedDevice = self.selectedDevice
            vc.bpChar = self.bpChar
            isNOUser = false
            Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        }
    }

    
    
}
