//
//  AccessTypesViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/15.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework

enum AccessTypes: Int {
    case Permanent = 0
    case Schedule = 1
    case AccessTimes = 2
    case Recurrent = 3
}

class AccessTypesViewController: BLE_ViewController{

    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 0
    let kDateEndRow   = 1
    
    let kDateCellID       = "dateCell";       // the cells with the start or end date
    let kDatePickerCellID = "datePickerCell"; // the cell containing the date picker
    let kOtherCellID      = "otherCell";      // the remaining cells at the end
    let kRepeatCellID      = "repeatCell";      // the
    var dataArray: [[String: AnyObject]] = []
    var dateFormatter = DateFormatter()
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: IndexPath?
    
    var pickerCellRowHeight: CGFloat = 216
    static var startTimeArr: Array<Int>!
    static var endTimeArr: Array<Int>!
    static var openTimes: Int!
    static var weekly: UInt8!
    var isEnableStatus:UInt8!
    var limitType: UInt8!
    var userIndex :Int16 = 0
    var recurrentDateArray: [[String: AnyObject]] = []
    var recurrentDatePickerIndexPath: IndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    var accessType: AccessTypes = .Permanent
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = GetSimpleLocalizedString("Access Types/Schedule")
        tableView.register(R.nib.accessTimesTableViewCell)
        tableView.register(R.nib.datePickerTableViewCell)
        tableView.register(R.nib.dateTableViewCell)
        tableView.register(R.nib.repeatTableViewCell)
        // setup our data source
        
        let itemStart = [kTitleKey : GetSimpleLocalizedString("Start"), kDateKey : Date()] as [String : Any]
        let itemEnd = [kTitleKey : GetSimpleLocalizedString("End"), kDateKey : Date()] as [String : Any]
        let itemRepeat = [kTitleKey : GetSimpleLocalizedString("Repeat")] as [String : Any]
        dataArray = [itemStart as Dictionary<String, AnyObject>, itemEnd as Dictionary<String, AnyObject>]
         recurrentDateArray = [itemStart as Dictionary<String, AnyObject>, itemEnd as Dictionary<String, AnyObject>, itemRepeat as Dictionary<String, AnyObject>]
        //dateTableViewCell.textLabel?.text = itemData[kTitleKey] as? String
       
        //dateTableViewCell.detailTextLabel?.text = self.dateFormatter.string(from: itemData[kDateKey] as! Date)
        //dateFormatter.dateStyle = .medium // show short-style date format
        //dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        // if the locale changes while in the background, we need to be notified so we can update the date
        // format in the table view cells
        //
        NotificationCenter.default.addObserver(self, selector: #selector(AccessTypesViewController.localeChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        
        UserInfoTableViewController.isSettingAccess = true
      
         UserInfoTableViewController.tmpCMD = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime: Util.toUInt8date(AccessTypesViewController.startTimeArr), endTime:  Util.toUInt8date(AccessTypesViewController.endTimeArr), Times: UInt8(AccessTypesViewController.openTimes), weekly: AccessTypesViewController.weekly)
    }

    func localeChanged(_ notif: Notification) {
        // the user changed the locale (region format) in Settings, so we are notified here to
        // update the date format in the table view cells
        //
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        
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


extension AccessTypesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 1 && accessType == .Schedule{
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
        }
        else if indexPath.section == 1 && accessType == .Recurrent
        {
            
            return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
            
        }
        else{
        return 44
        }
    }
     func tableView(_ tableView: UITableView, willDisplayHeaderView view:UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.black        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section
        {
        case 1:
            
            switch accessType
            {
            case .Schedule:
                return GetSimpleLocalizedString("Schedule")
            case .AccessTimes:
                return GetSimpleLocalizedString("Access Times")
            case .Recurrent:
                return GetSimpleLocalizedString("Recurrent")
            default:
                return ""
            }
        default:
            return GetSimpleLocalizedString("TYPES")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch accessType {
        case .Schedule, .AccessTimes, .Recurrent:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1
        {
            switch accessType
            {
            case .Permanent:    return 0
            case .Schedule:
                if hasInlineDatePicker()
                {
                    // we have a date picker, so allow for it in the number of rows in this section
                    return dataArray.count + 1;
                }
                return dataArray.count;
                
            case .AccessTimes:  return 1
            case .Recurrent:
                if hasInlineDatePicker()
                {
                    // we have a date picker, so allow for it in the number of rows in this section
                    return recurrentDateArray.count + 1;
                }
                return recurrentDateArray.count;
            }

        }
        else
        {
            return Config.accessTypesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        var cell: UITableViewCell?
        
        if indexPath.section == 0
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell?.selectionStyle = .none
            cell?.tintColor = HexColor("00b900")
            cell?.textLabel?.text = "\(Config.accessTypesArray[indexPath.row])"
            cell?.textLabel?.textColor = HexColor("4a4a4a")
            
            if indexPath.row == accessType.rawValue
            {
                cell?.accessoryType = .checkmark
            }
            else
            {
                cell?.accessoryType = .none
            }
        }
        else
        {
            switch accessType
            {
            case .Schedule:
//                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                
                var cellID = kDateCellID
                
                if indexPathHasPicker(indexPath) {
                    // the indexPath is the one containing the inline date picker
                    cellID = kDatePickerCellID     // the current/opened date picker cell
                } else if indexPathHasDate(indexPath) {
                    // the indexPath is one that contains the date information
                    cellID = kDateCellID       // the start/end date cells
                }
                
                cell = tableView.dequeueReusableCell(withIdentifier: cellID)
//                let datePickerTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.datePickerTableViewCell.identifier, for: indexPath) as! DatePickerTableViewCell
//                cell = datePickerTableViewCell
                
                
                if indexPath.row == 0 {
                    // we decide here that first cell in the table is not selectable (it's just an indicator)
                    cell?.selectionStyle = .none;
                }
                
                // if we have a date picker open whose cell is above the cell we want to update,
                // then we have one more cell than the model allows
                //
                var modelRow = indexPath.row
                if (datePickerIndexPath != nil && (datePickerIndexPath?.row)! <= indexPath.row)
                {
                    modelRow -= 1
                }
                
                let itemData = dataArray[modelRow]
                
                if cellID == kDateCellID
                {
                    let dateTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.dateTableViewCell.identifier, for: indexPath) as! DateTableViewCell
                    
                    // we have either start or end date cells, populate their date field
                    //
                    var dateStr = ""
                    
                    
                     if indexPath.row == 0 {
                        
                     dateStr = self.dateFormatter.string(from: getCmdDate(timeArr: AccessTypesViewController.startTimeArr))
                     }else if indexPath.row == 1 {
                      dateStr = self.dateFormatter.string(from: getCmdDate(timeArr: AccessTypesViewController.endTimeArr))
                    
                    }
                        
                    
                   
                    dateTableViewCell.textLabel?.text = itemData[kTitleKey] as? String
                    dateTableViewCell.textLabel?.textColor = HexColor("4a4a4a")
                    dateTableViewCell.detailTextLabel?.text = dateStr
                    dateTableViewCell.detailTextLabel?.textColor = HexColor("4a4a4a")
                    dateTableViewCell.detailTextLabel?.font = .systemFont(ofSize: 17)
                    cell = dateTableViewCell
                }
                
                else if cellID == kDatePickerCellID
                {
                    let datePickerTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.datePickerTableViewCell.identifier, for: indexPath) as! DatePickerTableViewCell
                    datePickerTableViewCell.delegate = self
                    datePickerTableViewCell.datePicker.datePickerMode = .dateAndTime
                    cell = datePickerTableViewCell
                }
                else if cellID == kRepeatCellID
                {
                    cell?.textLabel?.text = itemData[kTitleKey] as? String
                }
//                else if cellID == kOtherCellID {
//                    // this cell is a non-date cell, just assign it's text label
//                    //
//                    cell?.textLabel?.text = itemData[kTitleKey] as? String
//                }
                
            
            case .AccessTimes:
                let accessTimesTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.accessTimesTableViewCell.identifier, for: indexPath) as! AccessTimesTableViewCell
                accessTimesTableViewCell.accessTimesTextField.becomeFirstResponder()
                
                accessTimesTableViewCell.setTimesValue(times: AccessTypesViewController.openTimes)
                accessTimesTableViewCell.setViewController(controller: self)
                cell = accessTimesTableViewCell
                
            case .Recurrent:
                var cellID = kRepeatCellID
                
                if indexPathHasPicker(indexPath) {
                    // the indexPath is the one containing the inline date picker
                    cellID = kDatePickerCellID     // the current/opened date picker cell
                } else if indexPathHasDate(indexPath) {
                    // the indexPath is one that contains the date information
                    cellID = kDateCellID       // the start/end date cells
                }
                
                cell = tableView.dequeueReusableCell(withIdentifier: cellID)
                
                if indexPath.row == 0 {
                    // we decide here that first cell in the table is not selectable (it's just an indicator)
                    cell?.selectionStyle = .none;
                }
                
                // if we have a date picker open whose cell is above the cell we want to update,
                // then we have one more cell than the model allows
                //
                var modelRow = indexPath.row
                if (recurrentDatePickerIndexPath != nil && (recurrentDatePickerIndexPath?.row)! <= indexPath.row)
                {
                    modelRow -= 1
                }
                
                let itemData = recurrentDateArray[modelRow]
                
                if cellID == kDateCellID
                {
                    let dateTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.dateTableViewCell.identifier, for: indexPath) as! DateTableViewCell
                    let calendar = Calendar.current
                    let currentdate = Date()
                    var dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from:  currentdate)
                    print(String(format:" text before Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
                    if indexPath.row == 0 {
                        print("startARR\r\n")
                        dateComponents.year = AccessTypesViewController.startTimeArr[0]
                        dateComponents.month = AccessTypesViewController.startTimeArr[1]
                        dateComponents.day = AccessTypesViewController.startTimeArr[2]
                        dateComponents.hour = AccessTypesViewController.startTimeArr[3]
                        dateComponents.minute = AccessTypesViewController.startTimeArr[4]
                        dateComponents.second = AccessTypesViewController.startTimeArr[5]
                    }else if indexPath.row == 1 {
                        print("endARR\r\n")
                        dateComponents.year = AccessTypesViewController.endTimeArr[0]
                        dateComponents.month = AccessTypesViewController.endTimeArr[1]
                        dateComponents.day = AccessTypesViewController.endTimeArr[2]
                        dateComponents.hour = AccessTypesViewController.endTimeArr[3]
                        dateComponents.minute = AccessTypesViewController.endTimeArr[4]
                        dateComponents.second = AccessTypesViewController.endTimeArr[5]
                    }
                    print(String(format:"text after Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
                    
                    // we have either start or end date cells, populate their date field
                    dateTableViewCell.textLabel?.text = itemData[kTitleKey] as? String
                     dateTableViewCell.detailTextLabel?.text = String(format: "%02d",dateComponents.hour!) + ":" + String(format: "%02d",dateComponents.minute!)
                    
                    dateTableViewCell.textLabel?.textColor = HexColor("4a4a4a")
                    
                    dateTableViewCell.detailTextLabel?.textColor = HexColor("4a4a4a")
                    dateTableViewCell.detailTextLabel?.font = .systemFont(ofSize: 17)
                    cell = dateTableViewCell
                }
                    
                else if cellID == kDatePickerCellID
                {
                    let datePickerTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.datePickerTableViewCell.identifier, for: indexPath) as! DatePickerTableViewCell
                    datePickerTableViewCell.delegate = self
                    datePickerTableViewCell.datePicker.datePickerMode = .time
                    cell = datePickerTableViewCell
                }
                else if cellID == kRepeatCellID
                {    let weekString = [GetSimpleLocalizedString("weekly_Sun"), GetSimpleLocalizedString("weekly_Mon"), GetSimpleLocalizedString("weekly_Tue"), GetSimpleLocalizedString("weekly_Wed"), GetSimpleLocalizedString("weekly_Thu"), GetSimpleLocalizedString("weekly_Fri"), GetSimpleLocalizedString("weekly_Sat")]
                    var weekText = ""
                    print(String(format:"%02x",AccessTypesViewController.weekly))
                    var count:Int = 0
                    if AccessTypesViewController.weekly != 0x7f {
                    
                    for n: UInt8 in 0...6{
                        
                        if (AccessTypesViewController.weekly & (0x1 << n)) != 0{
                                                        weekText += weekString[Int(n)]
                            count += 1
                        
                        }
                        }
                    }else{
                        weekText =  self.GetSimpleLocalizedString("Every Week")

                    }
 
                    let repeatTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.repeatTableViewCell.identifier, for: indexPath) as! RepeatTableViewCell
                    
                    if count < 7{
                       repeatTableViewCell.detailTextLabel?.font =  repeatTableViewCell.detailTextLabel?.font.withSize(12)
                    }else{
                    repeatTableViewCell.detailTextLabel?.font =  repeatTableViewCell.detailTextLabel?.font.withSize(17)
                    }
                    
                    repeatTableViewCell.textLabel?.text = self.GetSimpleLocalizedString("Repeat")
                    repeatTableViewCell.textLabel?.textColor = HexColor("4a4a4a")
                   
                    repeatTableViewCell.detailTextLabel?.text = weekText
                   repeatTableViewCell.textLabel?.textColor = HexColor("4a4a4a")
                    
                    cell = repeatTableViewCell
                }

            default:
                break
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        var limitType:UInt8 = 0x00
        if indexPath.section == 0
        {

            if accessType.rawValue != indexPath.row
            {

                if let unSelectedCell = tableView.cellForRow(at: IndexPath(row: accessType.rawValue, section: 0))
                {
                    unSelectedCell.accessoryType = .none
                }
                tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
                accessType = AccessTypes(rawValue: indexPath.row)!
                switch accessType
                {
                case .Permanent:
                    limitType  = 0x00
                    UserInfoTableViewController.titleForFooter = ""
                    
                case .Schedule:
                     limitType  = 0x01
                     
                    let StartTimeArr = AccessTypesViewController.startTimeArr
                    
                    let EndTimeArr = AccessTypesViewController.endTimeArr
                    
                    let startTimerStr =  "\(String(format: "%04d",(StartTimeArr?[0])!))/\(String(format: "%02d",(StartTimeArr?[1])!))/\(String(format: "%02d",(StartTimeArr?[2])!))" + " " + String(format: "%02d",(StartTimeArr?[3])!) + ":" + String(format: "%02d",(StartTimeArr?[4])!)
                    
                    let endTimerStr =  "\(String(format: "%04d",(EndTimeArr?[0])!))/\(String(format: "%02d",(EndTimeArr?[1])!))/\(String(format: "%02d",(EndTimeArr?[2])!))" + " " + String(format: "%02d",(EndTimeArr?[3])!) + ":" + String(format: "%02d",(EndTimeArr?[4])!)
                
                UserInfoTableViewController.titleForFooter =  startTimerStr + "~" + endTimerStr + "\n"
                    
                case .AccessTimes:
                    limitType  = 0x02
                    UserInfoTableViewController.titleForFooter = GetSimpleLocalizedString("users_edit_access_control_dialog_type_times_mark") + "\((String(format:"%02d",AccessTypesViewController.openTimes!)))" + "\n"
                    
                case .Recurrent:
                    limitType  = 0x03
                    let StartTimeArr = AccessTypesViewController.startTimeArr
                    
                    let EndTimeArr = AccessTypesViewController.endTimeArr
                    let weekString = [GetSimpleLocalizedString("weekly_Sun"), GetSimpleLocalizedString("weekly_Mon"), GetSimpleLocalizedString("weekly_Tue"), GetSimpleLocalizedString("weekly_Wed"), GetSimpleLocalizedString("weekly_Thu"), GetSimpleLocalizedString("weekly_Fri"), GetSimpleLocalizedString("weekly_Sat")]
                    var weekText = ""
                    print(String(format:"%02x",AccessTypesViewController.weekly))
                    for n: UInt8 in 0...6{
                        
                        if (AccessTypesViewController.weekly & (0x1 << n)) != 0{
                            weekText += weekString[Int(n)]
                        }
                    }
                    
                    let startTimerStr =  String(format: "%02d",(StartTimeArr?[3])!) + ":" + String(format: "%02d",(StartTimeArr?[4])!)
                    
                    let endTimerStr = String(format: "%02d",(EndTimeArr?[3])!) + ":" + String(format: "%02d",(EndTimeArr?[4])!)
                    
                    
                     UserInfoTableViewController.titleForFooter =  weekText + "\n" + startTimerStr + " ~ " + endTimerStr
                default:
                    UserInfoTableViewController.titleForFooter = ""
                }
                //limitType = 0x00
                
              
                UserInfoTableViewController.tmpCMD = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: limitType, startTime: Util.toUInt8date(AccessTypesViewController.startTimeArr), endTime:  Util.toUInt8date(AccessTypesViewController.endTimeArr), Times: UInt8(AccessTypesViewController.openTimes), weekly: AccessTypesViewController.weekly)
                    tableView.reloadData()
            }
            
            updateDatePicker()
        }
        else
        {
            switch accessType
            {
                
            
            case .Schedule:
                  UserInfoTableViewController.tmpCMD = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: 0x01, startTime: Util.toUInt8date(AccessTypesViewController.startTimeArr), endTime:  Util.toUInt8date(AccessTypesViewController.endTimeArr), Times: UInt8(AccessTypesViewController.openTimes), weekly: AccessTypesViewController.weekly)
                  
                let cell = tableView.cellForRow(at: indexPath)
                if cell?.reuseIdentifier == kDateCellID{
                       
                    displayInlineDatePickerForRowAtIndexPath(indexPath)
                } else {
                    print("data\r\n")
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            case .AccessTimes:
                
                       //limitType = 0x02
                       
                       UserInfoTableViewController.tmpCMD = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: 0x02, startTime: Util.toUInt8date(AccessTypesViewController.startTimeArr), endTime:  Util.toUInt8date(AccessTypesViewController.endTimeArr), Times: UInt8(AccessTypesViewController.openTimes), weekly: AccessTypesViewController.weekly)
                       
                
            case .Recurrent:
                
                UserInfoTableViewController.tmpCMD = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus,LimitType: 0x03, startTime: Util.toUInt8date(AccessTypesViewController.startTimeArr), endTime:  Util.toUInt8date(AccessTypesViewController.endTimeArr), Times: UInt8(AccessTypesViewController.openTimes), weekly: AccessTypesViewController.weekly)
                

                if (hasInlineDatePicker() && indexPath.row == 3) || (!hasInlineDatePicker() && indexPath.row == 2)
                {
                    let vc = RepeatDateViewController(nib: R.nib.repeatDateViewController)
                    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                    navigationController?.pushViewController(vc, animated: true)
                }
                else
                {
                    let cell = tableView.cellForRow(at: indexPath)
                    if cell?.reuseIdentifier == kDateCellID {
                        displayInlineDatePickerForRowAtIndexPath(indexPath)
                    } else {
                        tableView.deselectRow(at: indexPath, animated: true)
                    }
                }

                
            default:
                break
            }
        }
    }
    
    
    func didEdit(accessTimesTextField: UITextField){
        print("before count=\(accessTimesTextField.text?.utf8.count)")
        print("data=\(accessTimesTextField.text)")
        if ( ( accessTimesTextField.text?.utf8.count)! > 3) {
            accessTimesTextField.deleteBackward();
        }
        print("after count=\(accessTimesTextField.text?.utf8.count)")
        print("data=\(accessTimesTextField.text)")
        if accessTimesTextField.text != ""{
            if((accessTimesTextField.text?.contains("(format error)"))!){
                accessTimesTextField.text = String(format:"%d",AccessTypesViewController.openTimes)
            }
            
            if (accessTimesTextField.text?.utf8.count)! > 0  {
                AccessTypesViewController.openTimes = Int(accessTimesTextField.text!)!
            }
            
            if !((accessTimesTextField.text?.utf8.count)! > 0
                && (Int(accessTimesTextField.text!)!<=255)) {
                
                
                
                accessTimesTextField.text = accessTimesTextField.text! + NSLocalizedString("(format error)", comment: "")
                accessTimesTextField.textColor = UIColor.red
                
            }else{
                accessTimesTextField.textColor = UIColor.darkGray
                UserInfoTableViewController.tmpCMD[8] = 0x02
                UserInfoTableViewController.tmpCMD[23] = UInt8(accessTimesTextField.text!)!
                AccessTypesViewController.openTimes = Int(accessTimesTextField.text!)!
                
            }
        }
        
        
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(_ indexPath: IndexPath) {
        
        // display the date picker inline with the table content
        self.tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
             before = accessType == .Schedule ? (datePickerIndexPath?.row)! < indexPath.row : (recurrentDatePickerIndexPath?.row)! < indexPath.row
        }
        
       let sameCellClicked = accessType == .Schedule ? (datePickerIndexPath?.row == indexPath.row + 1) : (recurrentDatePickerIndexPath?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            if accessType == .Schedule
            {
                self.tableView.deleteRows(at: [IndexPath(row: datePickerIndexPath!.row, section: 1)], with: .fade)
                datePickerIndexPath = nil
            }
            else
            {
                self.tableView.deleteRows(at: [IndexPath(row: recurrentDatePickerIndexPath!.row, section: 1)], with: .fade)
                recurrentDatePickerIndexPath = nil
            }

        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = IndexPath(row: rowToReveal, section: 1)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            if accessType == .Schedule
            {
                datePickerIndexPath = IndexPath(row: indexPathToReveal.row + 1, section: 1)
            }
            else
            {
                recurrentDatePickerIndexPath = IndexPath(row: indexPathToReveal.row + 1, section: 1)
            }
      }
        
        // always deselect the row containing the start or end date
        self.tableView.deselectRow(at: indexPath, animated:true)
        
        self.tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func toggleDatePickerForSelectedIndexPath(_ indexPath: IndexPath) {
        print("toggleDatePickerForSelectedIndexPath")
        self.tableView.beginUpdates()
        
        let indexPaths = [IndexPath(row: indexPath.row + 1, section: 1)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath) {
            // found a picker below it, so remove it
            
            
            self.tableView.deleteRows(at: indexPaths, with: .fade)
            
            
        } else {
            // didn't find a picker below it, so we should insert it
            self.tableView.insertRows(at: indexPaths, with: .fade)
        }
        self.tableView.endUpdates()
    }
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
     */
    func getCmdDate(timeArr: Array<Int>)->Date{
    
        let calendar = Calendar.current
        let date:Date = Date()
        var dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: date)
        print(String(format:"before Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
            print("update start arr")
            dateComponents.year = timeArr[0]
            dateComponents.month = timeArr[1]
            dateComponents.day = timeArr[2]
            dateComponents.hour = timeArr[3]
            dateComponents.minute = timeArr[4]
            dateComponents.second = timeArr[5]
        
    
        return  calendar.date(from: dateComponents)!
    
    
    }
    
    func updateDatePicker() {
        
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = self.tableView.cellForRow(at: indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                if indexPath.row == 1 {
                    
                targetedDatePicker.date =  getCmdDate(timeArr: AccessTypesViewController.startTimeArr)
                }else if indexPath.row == 2{
                    
                 targetedDatePicker.date =  getCmdDate(timeArr: AccessTypesViewController.endTimeArr)
                
                }
                targetedDatePicker.setDate( targetedDatePicker.date, animated: false)
            }
        }
        else if let indexPath = recurrentDatePickerIndexPath
        {
            let associatedDatePickerCell = self.tableView.cellForRow(at: indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker?
            {
                if indexPath.row == 1 {
                    
                    targetedDatePicker.date =  getCmdDate(timeArr: AccessTypesViewController.startTimeArr)
                }else if indexPath.row == 2{
                    
                    targetedDatePicker.date =  getCmdDate(timeArr: AccessTypesViewController.endTimeArr)
                    
                }

            }
        }

    }
    
    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
     
     @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
     */
    func hasPickerForIndexPath(_ indexPath: IndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = self.tableView.cellForRow(at: IndexPath(row: targetedRow, section: 1))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
     */
    func hasInlineDatePicker() -> Bool {
         return accessType == .Schedule ?  datePickerIndexPath != nil :  recurrentDatePickerIndexPath != nil
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
     
     @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
     */
    func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return accessType == .Schedule ?
            hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row :
            hasInlineDatePicker() && recurrentDatePickerIndexPath?.row == indexPath.row
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
     
     @param indexPath The indexPath to check if it represents start/end date cell.
     */
    func indexPathHasDate(_ indexPath: IndexPath) -> Bool {
        var hasDate = false
        
        if (indexPath.row == kDateStartRow) || (indexPath.row == kDateEndRow || (hasInlineDatePicker() && (indexPath.row == kDateEndRow + 1))) {
            hasDate = true
        }
        return hasDate
    }
}

extension AccessTypesViewController:DatePickerTableViewCellDelegate{
    
    func didSelectDate(_ sender: UIDatePicker) {
        
        
        var targetedCellIndexPath: IndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            if accessType == .Schedule
            {
                targetedCellIndexPath = IndexPath(row: datePickerIndexPath!.row - 1, section: 1)
            }
            else
            {
                targetedCellIndexPath = IndexPath(row: recurrentDatePickerIndexPath!.row - 1, section: 1)
            }
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow!
        }
      
        let cell = tableView.cellForRow(at: targetedCellIndexPath!)
        let targetedDatePicker = sender
        print(String(format:"row=%d\r\n",targetedCellIndexPath!.row))
        // update our data model
        if accessType == .Schedule
        {
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date as AnyObject?
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        cell?.detailTextLabel?.text = dateFormatter.string(from: targetedDatePicker.date)
       
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: targetedDatePicker.date )
        print(String(format:"Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
        if targetedCellIndexPath!.row == 0{
        AccessTypesViewController.startTimeArr[0] = dateComponents.year!
        AccessTypesViewController.startTimeArr[1] = dateComponents.month!
        AccessTypesViewController.startTimeArr[2] = dateComponents.day!
        AccessTypesViewController.startTimeArr[3] = dateComponents.hour!
        AccessTypesViewController.startTimeArr[4] = dateComponents.minute!
            AccessTypesViewController.startTimeArr[5] = dateComponents.second!
        } else if targetedCellIndexPath!.row == 1{
        
            AccessTypesViewController.endTimeArr[0] = dateComponents.year!
            AccessTypesViewController.endTimeArr[1] = dateComponents.month!
            AccessTypesViewController.endTimeArr[2] = dateComponents.day!
            AccessTypesViewController.endTimeArr[3] = dateComponents.hour!
            AccessTypesViewController.endTimeArr[4] = dateComponents.minute!
            AccessTypesViewController.endTimeArr[5] = dateComponents.second!
        }
        
        UserInfoTableViewController.tmpCMD = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: 0x01, startTime: Util.toUInt8date(AccessTypesViewController.startTimeArr), endTime:  Util.toUInt8date(AccessTypesViewController.endTimeArr), Times: UInt8(AccessTypesViewController.openTimes), weekly: AccessTypesViewController.weekly)
        

            print("device Time= \(cell?.detailTextLabel?.text)")
        }else{
            // update our data model
            var itemData = recurrentDateArray[targetedCellIndexPath!.row]
            itemData[kDateKey] = targetedDatePicker.date as AnyObject?
            recurrentDateArray[targetedCellIndexPath!.row] = itemData
            
            // update the cell's date string
           
            let calendar = Calendar.current
            
            let dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: targetedDatePicker.date )
            print(String(format:"Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
            cell?.detailTextLabel?.text = String(format: "%02d",dateComponents.hour!) + ":" + String(format: "%02d",dateComponents.minute!)
            if targetedCellIndexPath!.row == 0{
                AccessTypesViewController.startTimeArr[0] = dateComponents.year!
                AccessTypesViewController.startTimeArr[1] = dateComponents.month!
                AccessTypesViewController.startTimeArr[2] = dateComponents.day!
                AccessTypesViewController.startTimeArr[3] = dateComponents.hour!
                AccessTypesViewController.startTimeArr[4] = dateComponents.minute!
                AccessTypesViewController.startTimeArr[5] = dateComponents.second!
                
            } else if targetedCellIndexPath!.row == 1{
                
                AccessTypesViewController.endTimeArr[0] = dateComponents.year!
                AccessTypesViewController.endTimeArr[1] = dateComponents.month!
                AccessTypesViewController.endTimeArr[2] = dateComponents.day!
                AccessTypesViewController.endTimeArr[3] = dateComponents.hour!
                AccessTypesViewController.endTimeArr[4] = dateComponents.minute!
                AccessTypesViewController.endTimeArr[5] = dateComponents.second!
            }
            
            UserInfoTableViewController.tmpCMD = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: isEnableStatus, LimitType: 0x03, startTime: Util.toUInt8date(AccessTypesViewController.startTimeArr), endTime:  Util.toUInt8date(AccessTypesViewController.endTimeArr), Times: UInt8(AccessTypesViewController.openTimes), weekly: AccessTypesViewController.weekly)
            

        }

        
    }
}
