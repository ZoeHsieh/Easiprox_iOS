//
//  MyButton.swift
//  E3AK
//
//  Created by 謝宇琋 on 2020/3/18.
//  Copyright © 2020 com.E3AK. All rights reserved.
//

import Foundation
import UIKit

class myButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.center.x = self.frame.width / 2
        self.imageView?.center.y = self.frame.height / 2 - (self.titleLabel?.frame.height)! / 2
        
        self.titleLabel?.frame = CGRect(x: 0, y: (self.imageView?.frame.origin.y)! + (self.imageView?.frame.height)!, width: self.frame.width, height: (self.titleLabel?.frame.height)!)
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        
    }
}
