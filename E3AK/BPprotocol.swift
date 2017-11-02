//
//  BPprotocol.swift
//  CBDoorLock
//
//  Created by BluePacket on 2017/3/30.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation

class BPprotocol{
    //E3AK cmd define
    public static let cmd_user_enroll:UInt8 =   0x01
    public static let cmd_user_identify:UInt8 = 0x02
    public static let cmd_keep_open:UInt8 = 0x03
    public static let cmd_device_time:UInt8 = 0x04
    public static let cmd_device_config:UInt8 = 0x05
    public static let cmd_device_name:UInt8 = 0x06
    public static let cmd_bd_addr:UInt8 = 0x07
    public static let cmd_fw_version:UInt8 = 0x08
    public static let cmd_admin_enroll:UInt8 = 0x09
    public static let cmd_admin_identify:UInt8 = 0x0A
    public static let cmd_admin_login:UInt8 = 0x0B
    public static let cmd_set_admin_pwd:UInt8 = 0x0C
    public static let cmd_user_property:UInt8 = 0x0D
    public static let cmd_user_info:UInt8 = 0x0E
    public static let cmd_user_add:UInt8 = 0x0F
    public static let cmd_user_del:UInt8 = 0x10
    public static let cmd_set_user_id:UInt8 = 0x11
    public static let cmd_set_user_pwd:UInt8 = 0x12
    public static let cmd_user_data:UInt8 = 0x13
    public static let cmd_user_bd_addr:UInt8 = 0x14
    public static let cmd_history_data:UInt8 = 0x15
    public static let cmd_user_counter:UInt8 = 0x16
    public static let cmd_history_counter:UInt8 = 0x17
    public static let cmd_data_lost:UInt8 = 0x18
    public static let cmd_erase_users:UInt8 = 0x19
    public static let cmd_history_next_Index:UInt8 = 0x1A
    public static let cmd_force_disconnect:UInt8 = 0x1B
    public static let cmd_sensor_degree:UInt8 = 0x1C
    public static let cmd_set_admin_card:UInt8 = 0x1D
    public static let cmd_set_user_card:UInt8 = 0x1E
    //cmd data len define
    public static let len_user_enroll:Int = 30
    public static let len_user_identify:Int = 16
    public static let len_admin_enroll:Int = 20
    public static let len_admin_identify:Int = 14
    public static let len_device_time:Int = 7
    public static let len_device_name:Int = 17
    public static let len_admin_login:Int = 14
    public static let len_set_admin_pwd:Int = 8
    public static let len_device_config:Int = 5
    public static let len_userproperty_read:Int = 2
    public static let len_userproperty_write:Int = 20
    public static let len_user_info:Int = 2
    public static let len_history:Int = 2
    public static let len_user_add:Int = 28
    public static let len_user_del:Int = 2
    public static let len_user_id:Int = 18
    public static let len_user_card:Int = 6
    public static let len_admin_card:Int = 4
    public static let len_user_pwd:Int = 10
    public static let len_user_data:Int = 54
    
    //cmd property define
    public static let result_success:UInt8 = 0x00
    public static let result_fail:UInt8 = 0x01
    public static let type_read:UInt8 = 0x00
    public static let type_write:UInt8 = 0x01
    public static let nullData:UInt8 = 0xFF
    public static let userID_maxLen:Int = 16
    public static let userPD_maxLen:Int = 8
    public static let userCardID_maxLen:Int = 10
    public static let packetHead_Tail:UInt8 = 0xC0
    public static let limit_Permanent:UInt8 = 0x00
    public static let limit_Schedule:UInt8 = 0x01
    public static let limit_Access_times:UInt8 = 0x02
    public static let limit_Recurrent:UInt8 = 0x03
    public static let sensor_level1:UInt8 = 0x01
    public static let sensor_level2:UInt8 = 0x02
    public static let sensor_level3:UInt8 = 0x03
    public static let userDataSize:Int = 54
    public static let door_status_delayTime:UInt8 = 0x00
    public static let door_status_KeepOpen:UInt8 = 0x01
    public static let spaceCardStr:String = " "
    public static let INVALID_CARD:String = "4294967295"
    public static let enable_card:UInt8 = 0x01
    public static let enable_phone:UInt8 = 0x02
    public static let enable_keypad:UInt8 = 0x04
    
    private let openType:UInt8 = 0x02
    private let openTypeKeep:UInt8 = 0x12
    
    private func getCmdWrite(cmdType:UInt8, data:[UInt8],datalen:Int)->[UInt8]
    {    var cmd = [UInt8] ()
        
            cmd.append(cmdType)
            cmd.append(BPprotocol.type_write)
            cmd.append((UInt8)(datalen >> 8))
            cmd.append((UInt8)(datalen & 0xFF))
        if datalen > 0 {
        for i in 0...Int(datalen) - 1{
            cmd.append(data[i])
            }
        }
        
        return cmd
    }
    
    private func getCmdRead(cmdType:UInt8)->[UInt8]{
        var cmd = [UInt8] ()
        cmd.append(cmdType)
        cmd.append(BPprotocol.type_read)
        cmd.append(0x00)
        cmd.append(0x00)
    

        return cmd
    }
    
    private func getCmdRead(cmdType:UInt8, data:[UInt8], datalen:Int) ->[UInt8]{
        var cmd = [UInt8] ()
        
        cmd.append(cmdType)
        cmd.append(BPprotocol.type_read)
        cmd.append((UInt8)(datalen >> 8))
        cmd.append((UInt8)(datalen & 0xFF))
        
        for i in 0...Int(datalen)-1 {
            cmd.append(data[i])
        }

        
        return cmd
    }
    
    private func slipEncode(data:[UInt8], len:Int)->[UInt8]{
        
        var packet = [UInt8]()
        
        packet.append(BPprotocol.packetHead_Tail)
        
        for i in 0 ... len - 1 {
           packet.append(data[i])
        }
        
        packet.append(BPprotocol.packetHead_Tail)
       /* print(String(format:"packet len=%d",len))
        
        for i in 0 ... packet.count - 1 {
            print(String(format:"packet[%d]=%02x",i,packet[i]))
            
        }*/
        return packet
    
    }
    
    public func setUserEnroll(UserID:[UInt8] , Password:[UInt8]) -> Data{
        
        let cmdData:[UInt8] = Config.userMac + Password + UserID
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_user_enroll, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserIndentify(UserIndex:Int) -> Data{
        //print("setUserIndex = \(UserIndex)")
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour,.minute,.second], from: Date())
        let Year: UInt16 = UInt16(components.year!)
        let Time = [ UInt8(Year >> 8), UInt8(Year & 0x00ff),UInt8(components.month!), UInt8(components.day!),  UInt8(components.hour!), UInt8(components.minute!), UInt8(components.second!)]
        let typeAndIndex = [openType, UInt8(UserIndex >> 8) , UInt8(UserIndex & 0x00ff)]
        //print(String(format:"typeAndIndex[%d]=%02x",1,typeAndIndex[1] ))
          //print(String(format:"typeAndIndex[%d]=%02x",2,typeAndIndex[2] ))
        
        let cmdData = Time + Config.userMac + typeAndIndex
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_user_identify, data: cmdData, datalen: cmdData.count)
        
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func setUserKeepOpen(UserIndex:Int) -> Data{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour,.minute,.second], from: Date())
        let Year: UInt16 = UInt16(components.year!)
        let Time = [ UInt8(Year >> 8), UInt8(Year & 0x00ff),UInt8(components.month!), UInt8(components.day!),  UInt8(components.hour!), UInt8(components.minute!), UInt8(components.second!)]
        let typeAndIndex = [openTypeKeep, UInt8(UserIndex >> 8) , UInt8(UserIndex & 0x00ff)]
        let cmdData = Time + Config.userMac + typeAndIndex
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_keep_open, data: cmdData, datalen: cmdData.count)
        
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func setDeviceTime(deviceTime:[UInt8]) -> Data{
      
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_device_time, data: deviceTime, datalen: 7)
        
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func getDeviceTime() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_device_time)
        
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func setDeviceConfig(door_option:UInt8, lockType:UInt8, delayTime:Int16, G_sensor_option:UInt8) -> Data{
       /* print("door=%02x",door_option)
          print("locktype=%02x",lockType)
          print("delayTime=%d",delayTime)
          print("g=%02x",G_sensor_option)*/
        
        let cmdData = [ door_option, lockType, UInt8(delayTime >> 8), UInt8(delayTime & 0x00FF), G_sensor_option]
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_device_config, data: cmdData, datalen: cmdData.count)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func getDeviceConfig() -> Data{
        
         let cmd = getCmdRead(cmdType: BPprotocol.cmd_device_config)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func setDeviceName(deviceName:[UInt8], nameLen:Int) -> Data{
        
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_device_name, data: deviceName, datalen: nameLen)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func getDeviceName() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_device_name)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func getDeviceBDAddr() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_bd_addr)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }

    public func getFW_version() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_fw_version)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func setAdminEnroll(UserID:[UInt8] , Password:[UInt8]) -> Data{
        
        let cmdData:[UInt8] = Config.userMac + Password + UserID
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_admin_enroll, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setAdminIndentify() -> Data{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour,.minute,.second], from: Date())
        let Year: UInt16 = UInt16(components.year!)
        let Time = [ UInt8(Year >> 8), UInt8(Year & 0x00ff),UInt8(components.month!), UInt8(components.day!),  UInt8(components.hour!), UInt8(components.minute!), UInt8(components.second!)]
    
        let cmdData = Time + Config.userMac + [openType]
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_admin_identify, data: cmdData, datalen: cmdData.count)
        
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func setAdminLogin() -> Data{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour,.minute,.second], from: Date())
        
        let Year: UInt16 = UInt16(components.year!)
        let Time = [ UInt8(Year >> 8), UInt8(Year & 0x00ff),UInt8(components.month!), UInt8(components.day!),  UInt8(components.hour!), UInt8(components.minute!), UInt8(components.second!)]
        
        let cmdData = Time + Config.userMac + [openType]
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_admin_login, data: cmdData, datalen: cmdData.count)
        
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func setAdminPWD(Password:[UInt8]) -> Data{
    
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_set_admin_pwd, data:  Password,datalen:  Password.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setAdminCard(Card:[UInt8]) -> Data{
        
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_set_admin_card, data:  Card,datalen:  BPprotocol.len_admin_card)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func getAdminPWD() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_set_admin_pwd)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    public func getAdminCard() -> Data{
        
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_set_admin_card)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    public func setSensorDegree(Level:UInt8)-> Data{
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_sensor_degree, data:  [Level],datalen:  1)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func readSensorDegree()-> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_sensor_degree)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserProperty(UserIndex:Int16, Keypadunlock:UInt8, LimitType:UInt8, startTime:[UInt8], endTime:[UInt8], Times:UInt8, weekly:UInt8) -> Data{
        
        var cmdData:[UInt8] = [UInt8(UserIndex >> 8)] + [UInt8(UserIndex & 0x00FF)]
       
        cmdData = cmdData + [Keypadunlock] + [LimitType]
        
        cmdData = cmdData + startTime + endTime
        cmdData = cmdData + [Times] + [weekly]
        //print(String(format:"bp time=%02x",Times))
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_user_property, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func getUserProperty(UserIndex:Int16) -> Data{
        
        let cmdData = [UInt8(UserIndex >> 8), UInt8(UserIndex & 0x00FF)]
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_user_property,data:cmdData, datalen: cmdData.count)
        
        return Data(bytes: slipEncode(data: cmd, len: cmd.count))
    }
    
    public func getUserInfo(UserCount:Int16) -> Data{
        
        let cmdData = [UInt8(UserCount >> 8), UInt8(UserCount & 0x00FF)]
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_user_info, data: cmdData, datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserAdd(Password:[UInt8], ID:[UInt8])-> Data{
        let cardData:[UInt8] = [0xFF, 0xFF, 0xFF, 0xFF]
        let cmdData:[UInt8] = Password + ID + cardData
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_user_add, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    public func setUserAdd(Password:[UInt8], ID:[UInt8], card:[UInt8]) -> Data{
        
        let cmdData:[UInt8] = Password + ID + card
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_user_add, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserDel(UserIndex:Int16) -> Data{
        
        let cmdData = [UInt8(UserIndex >> 8), UInt8(UserIndex & 0x00FF)]
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_user_del, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserID(UserIndex:Int16, ID:[UInt8]) -> Data{
        
    let cmdData:[UInt8] = [UInt8(UserIndex >> 8)] + [UInt8(UserIndex & 0x00FF)] + ID
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_set_user_id, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserPWD(UserIndex:Int16, Password:[UInt8]) -> Data{
        
        let cmdData:[UInt8] = [UInt8(UserIndex >> 8)] + [UInt8(UserIndex & 0x00FF)] + Password
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_set_user_pwd, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserCard(UserIndex:Int16, Card:[UInt8]) -> Data{
        
        let cmdData:[UInt8] = [UInt8(UserIndex >> 8)] + [UInt8(UserIndex & 0x00FF)] + Card
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_set_user_card ,data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setUserData(UserData:[UInt8]) -> Data{
        
        let cmdData:[UInt8] = UserData
        /*for i in 0 ... UserData.count - 1{
            print(String(format:"cmd data[%d]=%02x",i,cmdData[i]))
        }*/
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_user_data, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func getUserData(UserCount:Int16) -> Data{
        
        let cmdData:[UInt8] = [UInt8(UserCount >> 8)] + [UInt8(UserCount & 0x00FF)]
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_user_data, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    
    
    public func getUserBDAddr() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_user_bd_addr)
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func getHistoryData(historyCount:Int16) -> Data{
        
        let cmdData:[UInt8] = [UInt8(historyCount >> 8)] + [UInt8(historyCount & 0x00FF)]
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_history_data, data: cmdData,datalen: cmdData.count)
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func getUserCount() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_user_counter)
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func getHistoryCount() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_history_counter)
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setDataLost(UserIndex:Int16) -> Data{
        
        let cmdData = [UInt8(UserIndex >> 8), UInt8(UserIndex & 0x00FF)]
        
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_data_lost, data: cmdData,datalen: cmdData.count)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func setEraseUserList()->Data{
        
        let cmdData:[UInt8] = []
        let cmd = getCmdWrite(cmdType: BPprotocol.cmd_erase_users, data: cmdData,datalen: 0)
        
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    
    }

    public func getHistoryNextCount() -> Data{
        
        let cmd = getCmdRead(cmdType: BPprotocol.cmd_history_next_Index)
        return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    }
    
    public func excuteForceDisconnect() ->Data{
    
     let cmd = getCmdRead(cmdType: BPprotocol.cmd_force_disconnect)
     return Data(bytes:slipEncode(data:cmd,len:cmd.count))
    
    }

    
}
