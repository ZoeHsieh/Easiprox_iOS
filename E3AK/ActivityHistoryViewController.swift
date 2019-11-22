//
//  ActivityHistoryViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreBluetooth

class ActivityHistoryViewController: BLE_ViewController,UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var label_progress_dg_title: UILabel!
    
    @IBOutlet weak var label_progress_dg_msg: UILabel!
    @IBOutlet weak var pg_bar_progress_dg_view: UIProgressView!
    
    @IBOutlet weak var userIDTitle: UILabel!
    
    @IBOutlet weak var dateTitle: UILabel!
    
    @IBOutlet weak var openTypeTitle: UILabel!
    @IBOutlet weak var label_progress_dg_percent: UILabel!
    
    @IBOutlet weak var label_progress_dg_count: UILabel!
    
    
    @IBOutlet weak var downloadFrame: UIView!
    @IBOutlet weak var downloadView: UIView!
    
    @IBOutlet weak var progress_dg_btn_cancel: UIButton!
    
    @IBOutlet weak var progress_dg_btn_hide: UIButton!
    
    @IBAction func progress_dg_cancel_Action(_ sender: Any) {
        
        historyCount = 0
        historyReadIndex = 0
        Config.historyListArr.removeAll()
        localHistoryArr.removeAll()
        isDownloadViewShowing = false
        self.downloadFrame.removeFromSuperview();
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func progress_dg_hide_Action(_ sender: Any) {
        isDownloadViewShowing = false
        self.downloadFrame.removeFromSuperview();
        
    }
    var historyMax:Int16 = 0
    var historyCount:Int16 = 0
    var historyReadIndex:Int16 = 0
    //var isback = false
    var isDownloadViewShowing:Bool = false
    var localHistoryArr: [[String:Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = GetSimpleLocalizedString("Activity History")
        searchBar.placeholder = GetSimpleLocalizedString("Search")
        userIDTitle.text = GetSimpleLocalizedString("ID")
        dateTitle.text = GetSimpleLocalizedString("Date")
        
        openTypeTitle.text = GetSimpleLocalizedString("Lock Action")
        
        progress_dg_btn_hide.setTitle(self.GetSimpleLocalizedString("progress_dialog_hide_btn_title"), for: .normal)
        progress_dg_btn_cancel.setTitle(self.GetSimpleLocalizedString("progress_dialog_cancel_btn_title"), for: .normal)
        
        //searchBar.isHidden = false
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.placeholder = self.GetSimpleLocalizedString("History_search_placeHolder")
        tableView.register(R.nib.activityHistoryTableViewCell)
       
              
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: (R.image.researchGreen()), style: .done, target: self, action: #selector(didTapReloadItem)),
            UIBarButtonItem(image: (R.image.export()), style: .done, target: self, action: #selector(didTapshareItem))]
       
        navigationItem.rightBarButtonItem?.tintColor = HexColor("00B900")
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        
        if !Config.isHistoryDataOK
        {
            let cmd = Config.bpProtocol.getHistoryCount()
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        print("UserAppear")
       
        localHistoryArr = Config.historyListArr
        tableView.reloadData()
       
    }

    @objc func didTapReloadItem() {
        
        print("didTapReloadItem")
        if Config.isHistoryDataOK {
        Config.isHistoryDataOK = false
        
        historyCount  = 0
        historyReadIndex = 0
            
        pg_bar_progress_dg_view.setProgress(0, animated: true)
        pg_bar_progress_dg_view.progress = Float(0)
            Config.historyListArr.removeAll()
            localHistoryArr.removeAll()
        let cmd = Config.bpProtocol.getHistoryCount()
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
        }else{
            UIApplication.shared.keyWindow?.addSubview(self.downloadFrame);
            
            isDownloadViewShowing = true;
        }
    }
    
    func dataToCSV() -> String{
        var text = "\"No\",\"Name\",\"DateTime\",\"Type\"\n"
        var count = 0
        for data in Config.historyListArr{
            
            var userID = data["userID"] as! String
            let openType = data["openType"] as! UInt8
            let timeText = data["timeText"] as! String
            
            var osStr = ""
            switch openType{
            case 0:
                osStr = "Not Available"
            case 1:
                osStr = "Android"
            case 2:
                osStr = "iOS"
            case 3:
                osStr = GetSimpleLocalizedString("openType_Keypad")
            case 0x30:
                osStr = GetSimpleLocalizedString("openType_Alarm")
            case 0x31:
                osStr = GetSimpleLocalizedString("openType_Button")
            case 0x32:
                osStr = GetSimpleLocalizedString("Card")
            default:
                
                osStr = "unKnown"
            }
            print("userID = \(userID)")
            text += "\"\(count)\",\"\(userID)\",\"\(timeText)\",\"\(osStr)\"\n"
            count = count + 1
        }
        
        return text
    }

    
    @objc func didTapshareItem() {
        
        print("didTapshareItem")
        if Config.isHistoryDataOK {
            let date = Date()
            let calendar = Calendar.current
            let year  = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            let time = String(format:"%02d",year) + String(format:"%02d",month) + String(format:"%02d",day) + "_" + String(format:"%02d",hour) + String(format:"%02d",minutes)
            let path = NSTemporaryDirectory() + Config.deviceName + "_" + time + ".csv"
            let content = dataToCSV()
            do{
                try content.write(toFile: path, atomically: true, encoding: .utf8)
                
                let fileURL = URL(fileURLWithPath: path)
                let object = [fileURL]
                let actVC = UIActivityViewController(activityItems: object, applicationActivities: nil)
                actVC.popoverPresentationController?.sourceView = self.view
                actVC.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: 1.0,y :1.0), size: CGSize(width: self.view.bounds.size.width / 2.0, height: self.view.bounds.size.height / 2.0))
                self.present(actVC, animated: true, completion: nil)
            }catch{
                //showAlert(message: "Failed to export csv")
                print("Error: \(error.localizedDescription)")
            }

        /*
        let activityViewController = UIActivityViewController(activityItems: ["分享"], applicationActivities: nil)
        navigationController?.present(activityViewController, animated: true)
        {
            
            }*/
        }else{
        
            UIApplication.shared.keyWindow?.addSubview(self.downloadFrame);
            
            isDownloadViewShowing = true;
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateHistoryData(historyData:[UInt8]){
        
        let y = UInt16(historyData[2]) * 256 + UInt16(historyData[3])
        let m = historyData[4].toTimeString()
        let d = historyData[5].toTimeString()
        let hh = historyData[6].toTimeString()
        let mm = historyData[7].toTimeString()
        let ss = historyData[8].toTimeString()
        let timeText = "\(y)-\(m)-\(d) \(hh):\(mm):\(ss)"
        
        var userIDArray = [UInt8]()
        for j in 0 ... BPprotocol.userID_maxLen - 1{
            if historyData[j+9] != 0xFF && historyData[j+9] != 0x00{
                userIDArray.append(historyData[j+9])
            }
        }
        
        var userId = String(bytes: userIDArray, encoding: .utf8) ?? "No Name"
        
        if userId == Config.AdminID{
            
            userId = Config.AdminID_ENROLL
        }
        
        let openType = historyData[historyData.count - 1]
        if openType == 0x31{
            userId = GetSimpleLocalizedString("openType_Button")
        }else if openType == 0x30{
          userId = GetSimpleLocalizedString("Tamper Sensor")
        }
        historyCount += 1
        print("userid =\(userId)")
        Config.historyListArr.append(["userID":userId, "openType":openType, "timeText":timeText])
        
       
        
       
        let progressValue: Float = Float(historyCount) / Float(historyMax)
        print(progressValue)
        let prog_percent: Int = Int(progressValue * 100)
         
        
        //Update
        pg_bar_progress_dg_view.setProgress(progressValue, animated: true)
        label_progress_dg_percent.text = "\(prog_percent)%"
        label_progress_dg_count.text = "\(historyCount) / \(historyMax)"
        
         localHistoryArr = Config.historyListArr
        
        tableView.reloadData()
        
        
        
    }
    
    
    func showDownloadDialog() {
        
        if !Config.isHistoryDataOK {
            
          

            label_progress_dg_title.text = GetSimpleLocalizedString("download_dialog_title") + GetSimpleLocalizedString("settings_history_list")
            label_progress_dg_msg.text = GetSimpleLocalizedString("download_dialog_message")
            downloadFrame.frame = CGRect(origin: CGPoint(x:0 ,y:0), size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
            
            downloadView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
            
            
            UIApplication.shared.keyWindow?.addSubview(self.downloadFrame);
            
            isDownloadViewShowing = true;
            pg_bar_progress_dg_view.setProgress(0, animated: true)
            label_progress_dg_percent.text = "0%"
            label_progress_dg_count.text = "\(0) / \(historyMax)"
            
            
        }
        else {
            return
        }
    }

    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        for i in 0 ... cmd.count - 1{
            print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
        }
        if datalen == Int16(cmd.count - 4) {
            
            switch cmd[0]{
                
           case BPprotocol.cmd_history_counter:
                    historyMax = Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    print("history Max =%d",historyMax)
                    
                    let cmdData = Config.bpProtocol.getHistoryNextCount()
                    Config.bleManager.writeData(cmd: cmdData, characteristic: bpChar!)
                    
                break
            case BPprotocol.cmd_history_next_Index:
                historyReadIndex = Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF)) //- 1
                print("history Max =%d",historyReadIndex)
                if historyMax == 0 {
                   Config.isHistoryDataOK = true
                    pg_bar_progress_dg_view.progress = 0
                }else {
                    
                    showDownloadDialog()
                    let cmdData = Config.bpProtocol.getHistoryData(historyCount: historyReadIndex)
                    Config.bleManager.writeData(cmd: cmdData, characteristic: bpChar!)
                }
                break
                
            case BPprotocol.cmd_history_data:
                
                
                var data = [UInt8]()
                for i in 4 ... cmd.count - 1{
                    data.append(cmd[i])
                }
                // historyCount = Int16(UInt16(data[0])<<8 | UInt16(data[1] & 0x00FF))
                if (data[2] != 0xFF) && (data[3] != 0xFF){
                    updateHistoryData(historyData: data)
                }else{
                    historyCount += 1
                }
                if historyCount < historyMax {
                    if historyReadIndex == 0 {
                        historyReadIndex = historyMax
                    }else{
                        historyReadIndex -= 1
                    }
                    let cmdData = Config.bpProtocol.getHistoryData(historyCount: Int16(historyReadIndex))
                    Config.bleManager.writeData(cmd: cmdData, characteristic: bpChar!)
                }else{
                    
                    Config.isHistoryDataOK = true
                    pg_bar_progress_dg_view.progress = 100
                    delayOnMainQueue(delay: 0.1, closure: {
                        self.isDownloadViewShowing = false;
                        self.downloadFrame.removeFromSuperview();
                        self.localHistoryArr = Config.historyListArr
                        
                    })
                }
                
                break
                
                
            default:
                break

                
            }
        }
        
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
       
        
        
        if searchText == "" {
            
            localHistoryArr = Config.historyListArr
        } else {
            if Config.historyListArr.count == 0
            {
                localHistoryArr = Config.historyListArr
                return
            }
            
            localHistoryArr = []
            
            for i in 0 ... Config.historyListArr.count - 1 {
                let data:String = Config.historyListArr[i]["userID"] as! String
                
                if  data.localizedLowercase.hasPrefix(searchText.lowercased()) {
                    localHistoryArr.append(Config.historyListArr[i])
                }
            }
        }
        
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    ////
    override func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.downloadFrame.removeFromSuperview()
        
        
        backToMainPage()
        
    }
    

}


extension ActivityHistoryViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localHistoryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.activityHistoryTableViewCell.identifier, for: indexPath) as! ActivityHistoryTableViewCell
        
        if localHistoryArr.count > indexPath.row{
            let cellData = localHistoryArr[indexPath.row]
            if let name = cellData["userID"] as? String,
                let time = cellData["timeText"] as? String,
                let openType = cellData["openType"] as? UInt8{
                
                var osStr = ""
                print("history opentype=\(openType)")
                
                switch openType{
                case 0:
                    osStr = "Not Available"
                case 1:
                    osStr = "Android"
                case 2:
                    osStr = "iOS"
                case 3:
                    osStr = GetSimpleLocalizedString("openType_Keypad")
                case 0x30:
                    osStr = GetSimpleLocalizedString("openType_Alarm")
                case 0x31:
                   osStr = GetSimpleLocalizedString("openType_Button")
                case 0x32:
                    osStr = GetSimpleLocalizedString("Card")
                    
                default:
                    
                    osStr = "unKnown"
                }
               /* if openType == 0x30{
                    cell.nameLabel.text = GetSimpleLocalizedString("Tamper Alarm")
                }else{*/
                
                if openType == 0x30{
                    cell.nameLabel.textColor = UIColor.red
                    
                    
                    cell.dateLabel.textColor = UIColor.red

                    cell.deviceLabel.textColor = UIColor.red

                }else if openType == 0x31{
                    cell.nameLabel.textColor = UIColor.blue
                    
                    cell.dateLabel.textColor = UIColor.blue
                    cell.deviceLabel.textColor = UIColor.blue
                }else{
                
                    cell.nameLabel.textColor = UIColor.flatGreenDark()
                    cell.dateLabel.textColor = UIColor.flatGray()
                    cell.deviceLabel.textColor = UIColor.black
                }
                cell.nameLabel.text = name
                
                
                cell.dateLabel.text = time
                cell.deviceLabel.text = osStr
               
            }
        }

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !Config.isHistoryDataOK {
        UIApplication.shared.keyWindow?.addSubview(self.downloadFrame);
        
        isDownloadViewShowing = true;
        }
    }
    
    
   
    
}

