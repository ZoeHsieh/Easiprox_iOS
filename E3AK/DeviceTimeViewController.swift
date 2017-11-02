//
//  DeviceTimeViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/21.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import ChameleonFramework

class DeviceTimeViewController: BLE_ViewController {

    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateStartRow = 0
    let kDateEndRow   = 1
    
    let kDateCellID       = "dateCell";       // the cells with the start or end date
    let kDatePickerCellID = "datePickerCell"; // the cell containing the date picker
    let deviceTimeSwitchCellID      = "deviceTimeSwitchCell";      // the remaining cells at the end
    
    var dataArray: [[String: AnyObject]] = []
    var dateFormatter = DateFormatter()
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: IndexPath?
    
    var pickerCellRowHeight: CGFloat = 216
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = GetSimpleLocalizedString("Device Time")
        //tableView.register(R.nib.deviceTimeSwitchTableViewCell)
        tableView.register(R.nib.datePickerTableViewCell)
        tableView.register(R.nib.dateTableViewCell)
        
        //let itemStart = [kTitleKey : "automatic setting", kDateKey : Date()] as [String : Any]
        let itemEnd = [kTitleKey : GetSimpleLocalizedString("Device Time"), kDateKey : Date()] as [String : Any]
        dataArray = [itemEnd as Dictionary<String, AnyObject>]
       
       // dateFormatter.dateStyle = .medium // show short-style date format
       // dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        // if the locale changes while in the background, we need to be notified so we can update the date
        // format in the table view cells
        //
        NotificationCenter.default.addObserver(self, selector: #selector(DeviceTimeViewController.localeChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        displayInlineDatePickerForRowAtIndexPath(IndexPath(row: 1, section: 0))
         SettingsTableViewController.settingStatus = settingStatesCase.config_deviceTime.rawValue
       
        
    }

    func localeChanged(_ notif: Notification) {
        // the user changed the locale (region format) in Settings, so we are notified here to
        // update the date format in the table view cells
        //
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

extension DeviceTimeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPathHasPicker(indexPath) ? pickerCellRowHeight : tableView.rowHeight)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if hasInlineDatePicker() {
            // we have a date picker, so allow for it in the number of rows in this section
            return dataArray.count + 1;
        }
        
        return dataArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell?
        
        var cellID = kDateCellID
        
        if indexPathHasPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellID)

        
//        if indexPath.row == 0 {
//            // we decide here that first cell in the table is not selectable (it's just an indicator)
//        }
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && (datePickerIndexPath?.row)! <= indexPath.row) {
            modelRow -= 1
        }
        
        let itemData = dataArray[0]
        
        if cellID == kDateCellID {
            
            let dateTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.dateTableViewCell.identifier, for: indexPath) as! DateTableViewCell
            
            // we have either start or end date cells, populate their date field
            let calendar = Calendar.current
            let currentdate = Date()
            var dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from:  currentdate)
            print(String(format:" text before Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
            
            
                //dateComponents.year = SettingsTableViewController.startTimeArr[0]
               SettingsTableViewController.startTimeArr[0] = dateComponents.year!
                dateComponents.month = SettingsTableViewController.startTimeArr[1]
                dateComponents.day = SettingsTableViewController.startTimeArr[2]
                dateComponents.hour = SettingsTableViewController.startTimeArr[3]
                dateComponents.minute = SettingsTableViewController.startTimeArr[4]
                dateComponents.second = SettingsTableViewController.startTimeArr[5]
            
            print(String(format:"text after Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
            dateTableViewCell.textLabel?.text = itemData[kTitleKey] as? String
            
            dateTableViewCell.detailTextLabel?.textColor = HexColor("4a4a4a")
           
            
            dateTableViewCell.detailTextLabel?.text = self.dateFormatter.string(from: calendar.date(from: dateComponents)!)
           
            dateTableViewCell.detailTextLabel?.font = .systemFont(ofSize: 15)
            cell = dateTableViewCell
            
        }
        else if cellID == kDatePickerCellID
        {
            let datePickerTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.nib.datePickerTableViewCell.identifier, for: indexPath) as! DatePickerTableViewCell
            datePickerTableViewCell.delegate = self
            
            cell = datePickerTableViewCell
            let targetedDatePicker = cell?.viewWithTag(kDatePickerTag) as! UIDatePicker?
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: (targetedDatePicker?.date)!)
            print(String(format:"before Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
            print(String(format:"index=%d",indexPath.row))
            
            print("update start arr")
         //   dateComponents.year = SettingsTableViewController.startTimeArr[0]
            dateComponents.month = SettingsTableViewController.startTimeArr[1]
            dateComponents.day = SettingsTableViewController.startTimeArr[2]
            dateComponents.hour = SettingsTableViewController.startTimeArr[3]
            dateComponents.minute = SettingsTableViewController.startTimeArr[4]
            dateComponents.second = SettingsTableViewController.startTimeArr[5]
            
            targetedDatePicker?.date = calendar.date(from: dateComponents)!
            
            targetedDatePicker?.setDate( (targetedDatePicker?.date)!, animated: false)
            
            
        }
        /*else if cellID == deviceTimeSwitchCellID {
         
            let deviceTimeSwitchCell = tableView.dequeueReusableCell(withIdentifier: R.nib.deviceTimeSwitchTableViewCell.identifier, for: indexPath) as! DeviceTimeSwitchTableViewCell
            deviceTimeSwitchCell.delegate = self
            deviceTimeSwitchCell.indexPath = indexPath
            deviceTimeSwitchCell.titleLabel.text = itemData[kTitleKey] as? String
            cell = deviceTimeSwitchCell
        }*/
        
        cell?.selectionStyle = .none;
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = tableView.cellForRow(at: indexPath)
//        if cell?.reuseIdentifier == deviceTimeSwitchCellID {
//            displayInlineDatePickerForRowAtIndexPath(IndexPath(row: 1, section: 0))
//        } else {
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
    }
    
    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
     
     @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
     */
    func hasPickerForIndexPath(_ indexPath: IndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: 0))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
     */
    func updateDatePicker() {
       print("indexPath= \(datePickerIndexPath?.row)")
        if let indexPath = datePickerIndexPath {
            
            let associatedDatePickerCell = tableView.cellForRow(at: indexPath)
             if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker?
            {
            
               

                //let itemData = dataArray[self.datePickerIndexPath!.row - 1]
               // targetedDatePicker.setDate(itemData[kDateKey] as! Date, animated: false)
           }
            
        }
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
     */
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
     
     @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
     */
    func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return hasInlineDatePicker() && datePickerIndexPath?.row == indexPath.row
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
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func toggleDatePickerForSelectedIndexPath(_ indexPath: IndexPath) {
        tableView.beginUpdates()
        
        let indexPaths = [IndexPath(row: indexPath.row + 1, section: 0)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        tableView.endUpdates()
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(_ indexPath: IndexPath) {
        
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if hasInlineDatePicker() {
            before = (datePickerIndexPath?.row)! < indexPath.row
        }
        
        let sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker() {
            tableView.deleteRows(at: [IndexPath(row: datePickerIndexPath!.row, section: 0)], with: .fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = IndexPath(row: rowToReveal, section: 0)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = IndexPath(row: indexPathToReveal.row , section: 0)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRow(at: indexPath, animated:true)
        
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
}

extension DeviceTimeViewController: DatePickerTableViewCellDelegate{
    
    func didSelectDate(_ sender: UIDatePicker) {
        
        var targetedCellIndexPath: IndexPath?
        
        if self.hasInlineDatePicker() {
            // inline date picker: update the cell's date "above" the date picker cell
            targetedCellIndexPath = IndexPath(row: datePickerIndexPath!.row - 1, section: 0)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow!
        }
        
        let cell = tableView.cellForRow(at: targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date as AnyObject?
        dataArray[targetedCellIndexPath!.row] = itemData
        let calendar = Calendar.current
        // update the cell's date string
        cell?.detailTextLabel?.text = dateFormatter.string(from: targetedDatePicker.date)
       
        let dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: targetedDatePicker.date )
        print(String(format:"Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
            SettingsTableViewController.startTimeArr[0] = dateComponents.year!
        SettingsTableViewController.startTimeArr[1] = dateComponents.month!
         SettingsTableViewController.startTimeArr[2] = dateComponents.day!
        SettingsTableViewController.startTimeArr[3] = dateComponents.hour!
        SettingsTableViewController.startTimeArr[4] = dateComponents.minute!
        SettingsTableViewController.startTimeArr[5] = dateComponents.second!
             
        print("device Time= \(cell?.detailTextLabel?.text)")
        SettingsTableViewController.settingStatus = settingStatesCase.config_deviceTime.rawValue
    }
}

extension DeviceTimeViewController: DeviceTimeSwitchTableViewCellDelegate{
    
    func didTapSettingSwitch(_ indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == deviceTimeSwitchCellID {
         
        }else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

