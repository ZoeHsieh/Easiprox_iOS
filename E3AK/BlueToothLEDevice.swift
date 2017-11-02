//
//  BlueToothLEDevice.swift
//  E3AK
//
//  Created by BluePacket on 2017/4/18.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import Foundation
import CoreBluetooth



class BluetoothLEDevice{
private final var debugFlag:Bool = true
private static var centralManager:CBCentralManager!
private static var peripheral:CBPeripheral?
    
   public func Init(delegate:CBCentralManagerDelegate, UUID:CBUUID){
        
    BluetoothLEDevice.centralManager = CBCentralManager(delegate: delegate, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey : UUID])
    
    }
    public func Init(delegate:CBCentralManagerDelegate){
        
        BluetoothLEDevice.centralManager = CBCentralManager(delegate: delegate, queue: nil, options: nil)
        
        
    }
    public func release(){
        BluetoothLEDevice.centralManager.cancelPeripheralConnection(BluetoothLEDevice.peripheral!)
        
BluetoothLEDevice.peripheral = nil
        
        BluetoothLEDevice.centralManager = nil
    }
    
  public func isBLEPowerON()->Bool{
    
    
    return (BluetoothLEDevice.centralManager.state != .poweredOff)
  }

    public func isScanBLE()->Bool{
    
       return BluetoothLEDevice.centralManager.isScanning
    }
    
  public func ScanBLE(){
   
        if BluetoothLEDevice.centralManager.isScanning {
            if debugFlag{
                print("ScanBLE Central Manager is already scanning!!")
            }
            return
        } else {
            
            if (BluetoothLEDevice.centralManager.state == .poweredOn) {
                
                BluetoothLEDevice.centralManager.scanForPeripherals(withServices: [CBUUID(string:Config.serviceUUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
                if debugFlag {
                    print("Scanning Started!")
                }
            }
            
        }

    
    }
    public func ScanBLEStop(){
        
        if BluetoothLEDevice.centralManager.isScanning{
             BluetoothLEDevice.centralManager.stopScan()
            if debugFlag {
                print("Scanning Stoped!")
            }
            
        }
        
        
    }

    public func connect(bleDevice:CBPeripheral){
        BluetoothLEDevice.peripheral = bleDevice
        if (bleDevice.state == .connecting) {
            
            BluetoothLEDevice.centralManager.cancelPeripheralConnection((bleDevice))
            if debugFlag{
            print("Connecting Timeout!! --> Cancel")
            }
            
        }
        else {
           
            BluetoothLEDevice.centralManager?.connect((bleDevice), options: [CBConnectPeripheralOptionNotifyOnConnectionKey: false, CBConnectPeripheralOptionNotifyOnDisconnectionKey: false, CBConnectPeripheralOptionNotifyOnNotificationKey: false])
                print("Connecting to peripheral: \(String(describing: bleDevice.name))")
               
            
        }

    }
    
    public func disconnect(){
        
        guard let peripheral = BluetoothLEDevice.peripheral  else {
            print("No peripheral available to cleanup.")
            return
        }
        
        if peripheral.state != .connected {
            print("Peripheral is not connected.")
            BluetoothLEDevice.peripheral  = nil
            return
        }
       
            BluetoothLEDevice.centralManager.cancelPeripheralConnection(peripheral)
        

    
    }
    public func disconnectByCMD(char:CBCharacteristic){
        
        guard let peripheral = BluetoothLEDevice.peripheral  else {
            print("No peripheral available to cleanup.")
            return
        }
        
        if peripheral.state != .connected {
            print("Peripheral is not connected.")
            BluetoothLEDevice.peripheral  = nil
            return
        }
        let cmd = Config.bpProtocol.excuteForceDisconnect()
            writeData(cmd: cmd, characteristic: char)
      
        
        
    }

    public func setCentralManagerDelegate(vc_delegate:CBCentralManagerDelegate){
        BluetoothLEDevice.centralManager.delegate = vc_delegate
        
    }
    
    public func setPeripheralDelegate(vc_delegate:CBPeripheralDelegate){
        BluetoothLEDevice.peripheral?.delegate = vc_delegate 
    }
    
    func writeData(cmd:Data,characteristic:CBCharacteristic){
        
        var count = 0
        let cmd_len = cmd.count
        var buff = Data()
        if cmd_len > Config.BLE_MTU_MAX {
            while count + Config.BLE_MTU_MAX <= cmd_len {
                buff.removeAll()
                
                for i in 0 ... Config.BLE_MTU_MAX - 1{
                    buff.append(cmd[count+i])
                }
                for j in 0 ... buff.count - 1{
                    print(String(format:"count=%d,w-Buff=%02x" ,(count + j),buff[j]))
                }
                
                BluetoothLEDevice.peripheral?.writeValue(buff, for: characteristic, type: .withResponse)
                
                count += Config.BLE_MTU_MAX
            }
            //print(String(format:"count=%d" ,count))
        if(cmd_len != count){
            if count+1 < cmd_len{
                buff.removeAll()
               
                for i in 0 ... (cmd_len - count - 1){
                    buff.append(cmd[count+i])
                }
                for j in 0 ... buff.count - 1{
                    print(String(format:"count=%d,w-Buff3=%02x" ,(count + j) ,buff[j]))
                }
                
                BluetoothLEDevice.peripheral?.writeValue(buff, for: characteristic, type: .withResponse)
                
            }else{
                buff.removeAll()
                buff.append(cmd[count])
                  BluetoothLEDevice.peripheral?.writeValue(buff, for: characteristic, type: .withResponse)
            }
          }
        }  else {
            
            for j in 0 ... cmd.count - 1{
                print(String(format:"w-Buff_t=%02x" ,cmd[j]))
            }
            BluetoothLEDevice.peripheral?.writeValue(cmd, for: characteristic, type: .withResponse)
        }
        
    }

}


