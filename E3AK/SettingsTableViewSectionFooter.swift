//
//  SettingsTableViewSectionFooter.swift
//  E3AK
//
//  Created by BluePacketon 2017/6/23.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class SettingsTableViewSectionFooter: UITableViewCell {

    @IBOutlet weak var fwVRTitle: UILabel!
    @IBOutlet weak var fwVRLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        fwVRTitle.text = NSLocalizedString("settings_device_vr",comment: "")

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public func setVersion(version:String){
        fwVRLabel.text = version
    }
    
}
