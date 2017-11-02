//
//  UITextField.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/13.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

extension UITextField {
    
    func setTextFieldPaddingView() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        leftView = paddingView
        leftViewMode = .always;
    }
    
    func setTextFieldBorder() {
        layer.borderColor = HexColor("c8c7cc")?.cgColor
        layer.borderWidth = 1.0
    }
}
