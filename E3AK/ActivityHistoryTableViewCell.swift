//
//  ActivityHistoryTableViewCell.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/13.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class ActivityHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deviceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
