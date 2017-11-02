//
//  UsersTableViewCell.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/13.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var accountTitle: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBOutlet weak var passwordTitle: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var cardTitle: UILabel!
    
    @IBOutlet weak var cardLabel: UILabel!
    //@IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var disclosureImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

           accountTitle.text =  NSLocalizedString("ID", comment: "")
        
           passwordTitle.text = NSLocalizedString("Password", comment: "")
           cardTitle.text = NSLocalizedString("Card", comment: "")
          shadowView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   public func setArrowHide(_ isHide: Bool) {
        
        disclosureImageView.isHidden = isHide
    }
    
}
