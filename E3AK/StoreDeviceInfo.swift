//
//  StoreDeviceInfo.swift
//  E3AK
//
//  Created by BluePacket on 2017/3/28.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import CoreBluetooth

let expectLevel_Value_Suffix = "-value"
let expectLevel_isUsed_Suffix = "-used"
let device_LastIdentify_Ticks_Suffix = "-lastTick"


struct DeviceInfo {
    var UUID: UUID;
    var name: String;
    var peripheral: CBPeripheral;
    var model:String;
//    var color:String;
    var customID:String;
    var Category:String;
    var reserved:UInt8;
    var rssi: Int;
    var current_level: Int;
    var expect_level: Int;
    var alive: Int;
    
}

extension DeviceInfo: Equatable {
    static func == (lhs: DeviceInfo, rhs: DeviceInfo) -> Bool {
        return lhs.UUID == rhs.UUID
    }
}

extension DeviceInfo: Comparable {
    static func < (lhs: DeviceInfo, rhs: DeviceInfo) -> Bool {
        return lhs.current_level < rhs.current_level
    }
}

struct storeInfoKeys {
    static let dbVerion = "dbVersion";
    static let deviceListArray = "deviceListArray";
    
    //BackUp USE
    static let backUpData_isOK = "backUpData_isOK";
    static let backUpData_UsersList = "backUpData_UsersList";
    static let backUpData_Config_doorSensor = "backUpData_Config_doorSensor";
    static let backUpData_Config_doorLockType = "backUpData_Config_doorLockType";
    static let backUpData_Config_doorOpenTime = "backUpData_Config_doorOpenTime";
    static let backUpData_Config_enrollKey = "backUpData_Config_enrollKey";
    static let backUpData_Config_iRSensor = "backUpData_Config_iRSensor";

}

struct RestoreWorkItem {
    var characteristic: CBCharacteristic;
    var data: Data;
}
