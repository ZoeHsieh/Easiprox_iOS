//
//  UInt8_Extenstion.swift
//  E3AK
//
//  Created by BluePacket on 2017/7/3.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation

extension UInt8{
    
    func toTimeString() -> String{
        
        var text = "\(self)"
        if text.count < 2{
            text = "0" + text
        }
        return text
    }
    
}

extension Array{
    
    func toString() -> String{
        
        return "\(self[0])-\(self[1])-\(self[2]) \(self[3]):\(self[4]):\(self[5])"
    }
    
    func toTimeString() -> String{
        
        var result = ["\(self[3])", "\(self[4])", "\(self[5])"]
        for (i, text) in result.enumerated(){
            
            if text.count < 2{
                result[i] = "0" + result[i]
            }
        }
        return "\(result[0]):\(result[1]):\(result[2])"
    }
}
