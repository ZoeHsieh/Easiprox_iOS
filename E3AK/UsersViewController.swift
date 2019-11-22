//
//  UsersViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/13.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import CoreBluetooth


enum userViewStatesCase:Int {
    case userNone = 0
    case userAction = 1
    
}
class UsersViewController: BLE_ViewController,UISearchBarDelegate,AddUserViewControllerDelegate {
    
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var downloadFrame: UIView!
    @IBOutlet var downloadView: UIView!
    @IBOutlet weak var progress_dialog_title: UILabel!
    
    @IBOutlet weak var progress_dialog_bar: UIProgressView!
    @IBOutlet weak var progress_dialog_message: UILabel!
    
   
    @IBOutlet weak var progress_percentage: UILabel!
    
    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var progress_count: UILabel!
    @IBOutlet weak var addItem: UIBarButtonItem!
    @IBOutlet var msgFrame: UIView!
    @IBOutlet var msgView: UIView!
    
    @IBOutlet weak var label_msg_dg_title: UILabel!
    
    @IBOutlet weak var label_msg_dg_msg: UILabel!
    

    
    static var status:Int = 0
    static var result_userAction:Int = 0
    var localUserArr:[[String:Any]] = []
    var userMax:Int16 = 0
    var userCount:Int16 = 1
    var user_read_retry_cnt = 0
    var tmpUserIndexPath:IndexPath!
    var isDownloadViewShowing:Bool = false
    var isback = false
    var isDelelate = false
    
    @IBAction func progress_hide_Action(_ sender: Any) {
        isDownloadViewShowing = false
         self.downloadFrame.removeFromSuperview();
    }
    
    @IBAction func progress_cancel_Action(_ sender: Any) {
        userCount = 1
        Config.userListArr.removeAll()
        localUserArr.removeAll()
        isDownloadViewShowing = false
        self.downloadFrame.removeFromSuperview()
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func msg_dg_okAction(_ sender: Any) {
        
        self.msgFrame.removeFromSuperview();
              
        
    }
    
    @IBAction func backBefore(_ sender: Any) {
         isback = true
        print("backBefore")
        _ = self.navigationController?.popViewController(animated: true)
        if !Config.isUserListOK{
            Config.userListArr.removeAll()
            localUserArr.removeAll()
           
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = GetSimpleLocalizedString("Users")
        addItem.title = GetSimpleLocalizedString("Add")
        SearchBar.placeholder = GetSimpleLocalizedString("Search")
        SearchBar.delegate = self
        SearchBar.returnKeyType = UIReturnKeyType.done
        SearchBar.placeholder = self.GetSimpleLocalizedString("UserList_search_placeHolder")
        
        if Config.deviceType == Config.deviceType_Keypad{
            
            
            tableView.register(R.nib.usersTableViewCell_Keypad)
            
        }else{
            self.tableView.rowHeight = 120;
            tableView.register(R.nib.usersTableViewCell)
            
        }
        userCount = 1
        print(userMax)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        
        
        if !Config.isUserListOK && userMax > 0{
            Config.userListArr.removeAll()
            showDownloadDialog()
            let cmd = Config.bpProtocol.getUserInfo(UserCount: userCount)
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
            
            
        }else{
            print("Userload")
            if userMax == 0 && (Config.userListArr.count == 0) || (Config.userListArr.count == 0) {
              showMessageDialog(Title:"" , Message: GetSimpleLocalizedString("no_user_note"))
            }
             localUserArr = Config.userListArr
            tableView.reloadData()
        }
        UsersViewController.status = userViewStatesCase.userNone.rawValue
        
    }
    override func viewWillAppear(_ animated: Bool) {
         print("UserAppear")
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        switch UsersViewController.status {

        case userViewStatesCase.userAction.rawValue:
            if UsersViewController.result_userAction == 0{
            //self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
            
            }else{
            //self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
            
            }
            break
            
       
            
        default:
            break
        
        }
        localUserArr = Config.userListArr
        tableView.reloadData()
        UsersViewController.status = userViewStatesCase.userNone.rawValue
        
        
    }
    
    func didTapAdd(result:Bool) {
         
          Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
          Config.bleManager.setPeripheralDelegate(vc_delegate: self)
           localUserArr = Config.userListArr
           tableView.reloadData()
           
//           let cmdData = Config.bpProtocol.getUserCount()
//                Config.bleManager.writeData(cmd: cmdData, characteristic: bpChar)
        
       
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        
        if Config.isUserListOK{
        let vc = AddUserViewController(nib: R.nib.addUserViewController)
            vc.bpChar =  self.bpChar
            vc.delegate = self
        let navVC: UINavigationController = UINavigationController(rootViewController: vc)
            present(navVC, animated: true, completion: nil)
        }else{
        
            UIApplication.shared.keyWindow?.addSubview(self.downloadFrame)
            isDownloadViewShowing = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
         for i in 0 ... cmd.count - 1{
         print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
         }
        if datalen == Int16(cmd.count - 4) {
            
            switch cmd[0]{
            case BPprotocol.cmd_user_del:
                print("del 123")
                if cmd[4] == BPprotocol.result_success{
                    
                    if  isDelelate{
                     
                        Config.userListArr.remove(at: tmpUserIndexPath.row)
                        localUserArr = Config.userListArr
                        tableView.reloadData()
                      //  self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
                    }
                }
                else{
                    
                    //self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                }
                isDelelate = false
                break
                
            case BPprotocol.cmd_user_info:
                print("user info")
                if !isback{
                    if cmd[4] != 0xFF && cmd[4] != 0x00 {
                        var data = [UInt8]()
                        for i in 4 ... cmd.count - 1{
                            data.append(cmd[i])
                        }
                        updateUserInfo(userData: data)
                        
                        if userCount >= userMax {
                            Config.isUserListOK = true
                            print("download ok")
                            delayOnMainQueue(delay: 0.1, closure: {
                                self.isDownloadViewShowing = false;
                                self.downloadFrame.removeFromSuperview()
                                
                            })
                        }
                        
                    }else{
                        user_read_retry_cnt += 1
                    }
                    
                    if userCount <= userMax {
                        if user_read_retry_cnt == 5{
                            user_read_retry_cnt = 0;
                            userCount += 1;
                        }
                        print(String(format:"retry=%d\r\n",user_read_retry_cnt))
                        let cmdData = Config.bpProtocol.getUserInfo(UserCount: Int16(userCount))
                        
                        Config.bleManager.writeData(cmd: cmdData, characteristic: bpChar)
                        
                        
                    }
                }
                break
                
//            case BPprotocol.cmd_user_add:
//                self.localUserArr = Config.userListArr
//                tableView.reloadData()
//                break
                
                
                
            default:
                break
                
            }
        }
        
    }

    
    func updateUserInfo(userData:[UInt8]){
        
        
        var userIDArray = [UInt8]()
        for j in 0 ... BPprotocol.userID_maxLen - 1{
            if userData[j] != 0xFF && userData[j] != 0x00{
                userIDArray.append(userData[j])
            }
        }
        
        let userId = String(bytes: userIDArray, encoding: .utf8) ?? "No Name"
        
        
        var userPWDArray = [UInt8]()
        for j in 0 ... BPprotocol.userPD_maxLen - 1{
            if userData[j+16] != 0xFF && userData[j+16] != 0x00{
                userPWDArray.append(userData[j+16])
               
            }
        }
        
        
        var userCardArray = [UInt8]()
        var isCardSpaceCnt = 0
        for j in 0 ... 3{
            print(String(format:"%02x",userData[j+24]))
            if userData[j+24]==0xFF /*|| userData[j+24] == 0x00*/{
                isCardSpaceCnt+=1
                
            }
                userCardArray.append(userData[j+24])
                
        }
        
        print("cnt=\(isCardSpaceCnt)")
        
        let userPWD = String(bytes: userPWDArray, encoding: .utf8) ?? "No Name"
        var userCard = Util.UINT8toStringDecForCard(data: userCardArray, len: 4)
        let userIndex = Int16(UInt16(userData[28])<<8 | UInt16(userData[29] & 0x00FF))
        
        if isCardSpaceCnt == 4{
            userCard = BPprotocol.spaceCardStr
        }
        
        Config.userListArr.append(["pw":userPWD, "name":userId, "card":userCard ,"index":userIndex])
        localUserArr = Config.userListArr
        tableView.reloadData()
        
        
        let progressValue: Float = Float(userCount) / Float(userMax)
        let prog_percent: Int = Int(progressValue * 100)
        
        print(prog_percent)
        
        //Update Info
        progress_dialog_bar.setProgress(progressValue, animated: true)
        progress_percentage.text = "\(prog_percent)%"
        progress_count.text = "\(userCount) / \(userMax)"
        
        
        userCount += 1
        print(String(format:"count = %02d",userCount))
        
    }
    
    
    func showDownloadDialog() {
        
        
        //Set Initial Value
        progress_dialog_title.text = GetSimpleLocalizedString("download_dialog_title") + GetSimpleLocalizedString("settings_users_manage_list")
        progress_dialog_message.text = GetSimpleLocalizedString("download_dialog_message")
        downloadFrame.frame = CGRect(origin: CGPoint(x:0 ,y:0), size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
 
        downloadView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        
        UIApplication.shared.keyWindow?.addSubview(self.downloadFrame)
        
        isDownloadViewShowing = true;
        progress_dialog_bar.setProgress(0, animated: true)
        progress_percentage.text = "0%"
        progress_count.text = "\(0) / \(userMax)"
       
        
    }
    
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
       
        
        
        if searchText == "" {
            
            localUserArr = Config.userListArr
        } else {
            if Config.userListArr.count == 0
            {
                localUserArr = Config.userListArr
                return
            }
            
            localUserArr  = []
            
            for i in 0 ...  Config.userListArr.count - 1 {
                let data:String = Config.userListArr[i]["name"] as! String
                
                if  data.localizedLowercase.hasPrefix(searchText.lowercased()) {
                    localUserArr.append(Config.userListArr[i])
                }
            }
        }
        
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    override func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.downloadFrame.removeFromSuperview()
        
        
        backToMainPage()
        
    }
    
}

    


extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localUserArr.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        
        
        if Config.deviceType == Config.deviceType_Keypad{
            
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: R.nib.usersTableViewCell_Keypad, for: indexPath) as! UsersTableViewCell_Keypad
            
            if localUserArr.count > indexPath.row {
                guard localUserArr[indexPath.row]["name"] != nil else{
                    return cell2
                }
            }
            cell2.accountLabel.text = "\(localUserArr[indexPath.row]["name"] as! String)"
            
            
            cell2.passwordLabel.text = "\(localUserArr[indexPath.row]["pw"] as! String)"
            return cell2
            
        }else{
        
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.usersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
            
            if localUserArr.count > indexPath.row {
                guard localUserArr[indexPath.row]["name"] != nil else{
                    return cell
                }
            }
        cell.accountLabel.text = "\(localUserArr[indexPath.row]["name"] as! String)"
        
        
        cell.passwordLabel.text = "\(localUserArr[indexPath.row]["pw"] as! String)"
            
        cell.cardLabel.text = "\(localUserArr[indexPath.row]["card"] as! String)"
            
            return cell
        }
            
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Config.isUserListOK {
            
         let vc = R.storyboard.main.userInfoTableViewController()
             vc?.selectUser = indexPath.row
             vc?.bpChar = self.bpChar
            navigationController?.pushViewController(vc!, animated: true)
        }else{
             UIApplication.shared.keyWindow?.addSubview(self.downloadFrame)
            isDownloadViewShowing = true
        }
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
    
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "刪除"
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//        if editingStyle == .delete
//        {
//            
//        } else if editingStyle == .insert
//        {
//            // Not used in our example, but if you were adding a new row, this is where you would do it.
//        }
//    }
    
   
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let moreRowAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: GetSimpleLocalizedString("Delete"), handler:{action, indexpath in
            print("delete");
            if let userIndex = self.localUserArr[indexPath.row]["index"] as? Int16{
                print("del0")
                let cmdData = Config.bpProtocol.setUserDel(UserIndex: userIndex)
                
                Config.bleManager.writeData(cmd: cmdData, characteristic: self.bpChar!)
            }
            print("del1")
            self.tmpUserIndexPath = indexPath
            self.isDelelate = true
        });
        moreRowAction.backgroundColor = UIColor.red
        
        
        return [moreRowAction];

    }
    
   
    func showMessageDialog(Title:String, Message:String) {
        
        
        //Set Initial Value
        label_msg_dg_title.text = Title
        label_msg_dg_msg.text = Message
        msgFrame.frame = CGRect(origin: CGPoint(x:0 ,y:0), size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        msgView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        
        UIApplication.shared.keyWindow?.addSubview(self.msgFrame);
        
        
    }
    
    
  }
