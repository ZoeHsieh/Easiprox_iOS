//
//  Util.swift
//  E3AK
//
//  Created by BluePacket on 2017/3/31.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation


class Util{
    private static let  debug:Bool = true
    
    public static func StringtoUINT8(data: String, len: Int, fillData: UInt8) -> [UInt8]{
        var tmpData = [UInt8]()
        
        for _ in 0 ... len-1{
            tmpData.append(fillData)
        }
        
        //let dataUInt8: [UInt8] = data.unicodeScalars.map{ UInt8($0.value) }
       
        let dataUInt8: [UInt8] = Array(data.utf8)
        
        for j in 0 ... dataUInt8.count-1{
            tmpData[j] = dataUInt8[j]
        }
        
        return tmpData
    }
    
    public static func StringtoUINT8(data: String, len: Int) -> [UInt8]{
        
        //let dataUInt8: [UInt8] = data.unicodeScalars.map{ UInt8($0.value) }
        
        let dataUInt8: [UInt8] = Array(data.utf8)
        
        
        
        return dataUInt8
    }
    
    public static func StringDecToUINT8(data:String, len:Int)-> [UInt8]{
        
        var tmpData = [UInt8]()
        let dataInt = UInt32(data)!
        
       
        for i in 0 ... 3{
            let arrow = (3 - i ) * 8
         tmpData.append( UInt8(((dataInt >> arrow) & 0xFF)))
           
           
        }
        for j in 0 ... tmpData.count - 1 {
            print(String(format:"data[%d]=%02x\r\n",j,tmpData[j]))
        }
        return tmpData
    }
    public static func UINT8toStringDecForCard(data:[UInt8], len:Int)-> String{
        
        var dataInt:UInt32 = 0
        var tmpByte: UInt32 = 0
        var checkCnt = 0
        for i in 0 ... 3{
            let arrow = (3 - i ) * 8
            tmpByte = UInt32(data[i])
            dataInt |= (tmpByte << arrow)
            print(String(format:"data[%d]=%02x\r\nABA=%010u \r\n",i,data[i],dataInt))
            if(data[i]==0xFF){
                checkCnt += 1
            }
        }
        
        if(checkCnt == 4){
          return BPprotocol.spaceCardStr
        }
       
        return String(format:"%010u",dataInt)
    }
    
    public static func StringtoUINT8ForID(data: String, len: Int, fillData: UInt8) -> [UInt8]{
        var tmpData = [UInt8]()
        
        for _ in 0 ... len-1{
            tmpData.append(fillData)
        }
        
        //let dataUInt8: [UInt8] = data.unicodeScalars.map{ UInt8($0.value) }
        
        let dataUInt8: [UInt8] = Array(data.utf8)
        
        for j in 0 ... dataUInt8.count-1{
            tmpData[j] = dataUInt8[j]
        }
        
        if tmpData[dataUInt8.count-1] == 0x20{
           tmpData[dataUInt8.count-1] = 0xFF
        }
        
        return tmpData
    }

    public static func debugPrint(tag:String,message:String){
        if(debug){
            print(tag + ":" + message)
        }
    }
 
    public static func toUInt8date(_ arr: [Int]) -> [UInt8]{
        
        let byte1 = UInt16(arr[0])
        let uint8Time = [UInt8(byte1 >> 8), UInt8(byte1 & 0x00ff), UInt8(arr[1]), UInt8(arr[2]), //Day
            UInt8(arr[3]), UInt8(arr[4]), UInt8(arr[5])]
        return uint8Time
    }

}
