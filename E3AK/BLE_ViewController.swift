//
//  BLEProtocol.swift
//  E3AK
//
//  Created by BluePacket on 2017/7/3.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class BLE_ViewController: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var bpChar:CBCharacteristic!
    var tmpBuff = Data()
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("connected\r\n")
        peripheral.delegate = self
        Config.userListArr.removeAll()
        Config.historyListArr.removeAll()
        Config.isUserListOK = false
        Config.isHistoryDataOK = false

        delayOnMainQueue(delay: 0.5, closure: {
            peripheral.discoverServices([CBUUID(string:Config.serviceUUID)])
        })
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        backToMainPage()
        
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    // MARK: - CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            print("Error discovering services: \(error?.localizedDescription)")
            
           // dismiss(animated: true, completion: nil)
            return
        }
        
        if let services = peripheral.services {
            
            for service in services {
                
                print("Discovered service: \(service)")
                if service.uuid == CBUUID(string:Config.serviceUUID){
                    delayOnMainQueue(delay: 0.1, closure: {
                        peripheral.discoverCharacteristics([CBUUID(string:Config.charUUID)], for: service)
                        
                    })
                }
            }
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Discover Characteristics!!!")
        let characteristic = service.characteristics?[0]
        print("UUID=\(characteristic?.uuid.uuidString)")
        bpChar = characteristic
        peripheral.setNotifyValue(true, for: characteristic!)
        
        
        
        
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else{
            print("ERROR on reading value of \(characteristic.uuid): \(error?.localizedDescription)")
            return
        }
        
        if (characteristic.value != nil) {
            var rawData = characteristic.value
            for j in 0 ... (rawData?.count)! - 1 {
             
             print(String(format:"r[%d]=%02X",j,(rawData?[j])!))
             }
            
            
            tmpBuff = tmpBuff + rawData!
            /*for i in 0 ... (tmpBuff.count) - 1 {
             print(String(format:"total_tmp=%02X",(tmpBuff[i])))
             }*/
            if (tmpBuff.count) > 5{
                var count = 0
                var start_index = 0
                var end_index = 0
                var parseflag = false
                var cmdLen :Int = 0
                for i in 0 ... (tmpBuff.count) - 1{
                    if tmpBuff[i] == BPprotocol.packetHead_Tail{
                        count += 1
                        if count == 1{
                            start_index = i
                            cmdLen = Int((UInt16(tmpBuff[start_index+3])<<8 | UInt16(tmpBuff[start_index+4])&0x00FF)) + 4
                        }else if count == 2{
                            end_index = i
                            if (start_index < end_index) && (end_index - start_index - 1 == cmdLen){
                                parseflag = true
                                break
                            }else{
                                count -= 1
                            }
                        }
                    }
                }
                
                if parseflag{
                    
                    
                    var cmd = [UInt8]()
                    for i in start_index+1 ... end_index-1 {
                        cmd.append((tmpBuff[i]))
                    }
                    
                    cmdAnalysis(cmd: cmd)
                    
                    parseflag = false
                    let tmp = tmpBuff
                    tmpBuff.removeAll()
                    // print("end =%d \(end_index)")
                    //print("tmp count =%d \(tmp.count - 1)")
                    if end_index != tmp.count - 1 {
                        for j in end_index ... (tmp.count) - 1
                        {
                            tmpBuff.append(tmp[j])
                            
                        }
                        for i in 0 ... (tmpBuff.count) - 1 {
                            print(String(format:"tmp=%02X",(tmpBuff[i])))
                        }
                    }
                    
                    
                }
                
            }
        }
        
    
    }
   
    func cmdAnalysis(cmd:[UInt8]){
    
    }
    
    
     
}
