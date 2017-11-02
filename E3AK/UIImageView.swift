//
//  UIImageView.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func rotate360Degree() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z") // 在z軸旋轉
        rotationAnimation.toValue = CGFloat.pi*2 // 旋轉角度
        rotationAnimation.duration = 0.8 // 旋轉周期
        rotationAnimation.isCumulative = true // 旋轉累加角度
        rotationAnimation.repeatCount = Float.infinity // 旋轉次數
        layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stopRotate() {
        layer.removeAllAnimations()
    }
}
