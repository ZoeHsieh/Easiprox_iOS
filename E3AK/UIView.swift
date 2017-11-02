//
//  UIView.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/8.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import ChameleonFramework
import UIKit
import QuartzCore


extension UIView {
    
    func gradientBackground(percent: CGFloat){
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height * percent
        
        backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:CGRect(x:0, y:0, width:width, height:height), andColors:[HexColor("eeeeee")!, (HexColor("d8d8d8")?.withAlphaComponent(0.0))!])
        
        
//        backgroundColor = UIColor(gradientStyle:UIGradientStyle.topToBottom, withFrame:frame, andColors:[HexColor("eeeeee")!, UIColor.white])
    }
    
    func setShadowWithColor( color: UIColor?, opacity: Float?, offset: CGSize?, radius: CGFloat, viewCornerRadius: CGFloat?) {
        
        //layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: viewCornerRadius ?? 0.0).cgPath
        layer.shadowColor = color?.cgColor ?? UIColor.black.cgColor
        layer.shadowOpacity = opacity ?? 1.0
        layer.shadowOffset = offset ?? CGSize.zero
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }    
}




