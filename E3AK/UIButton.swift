//
//  UIButton.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/19.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func adjustButtonEdgeInsets() {
        
        let spacing:CGFloat = 6.0
        
        // lower the text and push it left so it appears centered
        //  below the image
        let imageSize = imageView?.frame.size
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize!.width, bottom: -(imageSize!.height + spacing), right: 0.0)
        
        // raise the image and push it right so it appears centered/        //  above the text
        let titleSize: CGSize = (titleLabel?.frame.size)!
        imageEdgeInsets = UIEdgeInsets( top: -(titleSize.height), left: 0.0, bottom: 0.0, right: -titleSize.width)
    }
}
