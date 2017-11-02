//
//  DatePickerTableViewCell.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/16.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate {
    func didSelectDate(_ sender: UIDatePicker)
}

class DatePickerTableViewCell: UITableViewCell {

    var delegate: DatePickerTableViewCellDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUIDate(timeArr: Array<Int>){
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: datePicker.date )
        print(String(format:"before Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
        dateComponents.year = timeArr[0]
        dateComponents.month = timeArr[1]
        dateComponents.day = timeArr[2]
        dateComponents.hour = timeArr[3]
        dateComponents.minute = timeArr[4]
        dateComponents.second = timeArr[5]
        print(String(format:"after Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
        datePicker.date = calendar.date(from: dateComponents)!
        
       datePicker.setDate(datePicker.date, animated: true)
    
    }

    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        delegate?.didSelectDate(sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
