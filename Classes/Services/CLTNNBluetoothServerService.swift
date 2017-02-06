//
//  CLTNNBluetoothServerService.swift
//  CLTNearNetworking
//
//  Created by Cc on 2017/2/5.
//  Copyright © 2017年 Cc. All rights reserved.
//

import UIKit
import CoreBluetooth

public class CLTNNBluetoothServerService: CLTNNServerNetworkNode {

    fileprivate let pCharacteristicUUID: CBUUID
    fileprivate let pServiceUUID: CBUUID
    fileprivate let pMaxConnections: Int
    
    fileprivate var pCentralManager: CBCentralManager? = nil
    fileprivate var pPeripheral: CBPeripheral? = nil
    fileprivate var pCharacteristic: CBCharacteristic? = nil

    fileprivate var pReceiveDataReader: CLTNNReceiveDataReader? = nil
    
    public init(serviceUUID: CBUUID, characteristicUUID: CBUUID, maxConnections:Int) {
        
        self.pServiceUUID = serviceUUID
        self.pCharacteristicUUID = characteristicUUID
        self.pMaxConnections = maxConnections
        
        super.init()
    }
    
    deinit {
        
        self.fReleaseCentralManager()
    }
    
    func fInitCentralManager() {
        
        if self.pCentralManager == nil {
            
            self.pCentralManager = CBCentralManager.init(delegate: self, queue: nil)
        }
    }
    
    func fReleaseCentralManager() {
        
        if self.pCentralManager != nil {
            
            self.pCentralManager?.stopScan()
            self.pCentralManager?.delegate = nil
            self.pCentralManager = nil
        }
        
        if self.pPeripheral != nil {
            
            self.pPeripheral?.delegate = nil
            self.pPeripheral = nil
        }
        
        if self.pCharacteristic != nil {
            
            self.pCharacteristic = nil
        }
    }
    
    override public func fStartListening() {
        
        self.fInitCentralManager()
    }
    
    override public func fStopListening() {
        
        self.fReleaseCentralManager()
    }
    
    override func fOnSendMsgToOther(writer: CLTNNSendDataWriter) {
        
        
    }
}

// MARK: -
extension CLTNNBluetoothServerService: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            
            self.pCentralManager?.scanForPeripherals(withServices: [self.pServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        default:
            print("[Client] 此设备不支持 BLE 4.0")
            break
        }
    }
    
    // 成功连接
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 发现服务
        self.pPeripheral = peripheral
        self.pPeripheral?.delegate = self
        self.pPeripheral?.discoverServices([self.pServiceUUID])
        
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        central.stopScan()
        if peripheral.state == .connected {
            
            central.retrieveConnectedPeripherals(withServices: [self.pServiceUUID])
        }
        else {
            
            self.pPeripheral = peripheral
            central.connect(peripheral, options: nil)
//            central.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
            
//            let dd = Data.init(bytes: [1])
//            peripheral.writeValue(dd, for: self.pCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        }
        

    }
    
    
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        if self.pPeripheral != nil {
            
            self.pPeripheral?.delegate = nil
            self.pPeripheral = nil
        }
    }
}

// MARK: -
extension CLTNNBluetoothServerService: CBPeripheralDelegate {
    
     public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            
            assert(false)
        }
        else {
            
            if peripheral.services == nil{
                
                return
            }
            
            for service in peripheral.services! {
                
                if service.uuid == self.pServiceUUID && peripheral == self.pPeripheral {
                    
                    peripheral.discoverCharacteristics([self.pCharacteristicUUID], for: service)
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
 
            assert(false)
        }
        else {
            
            if service.uuid == self.pServiceUUID && peripheral == self.pPeripheral {
                
                if service.characteristics == nil {
                    
                    return
                }
                
                for characteristic in service.characteristics! {
                
                    if characteristic.uuid == self.pCharacteristicUUID {
                        
                        self.pCharacteristic = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            
            assert(false)
        }
        else {
            
            if characteristic.uuid == self.pCharacteristicUUID && peripheral == self.pPeripheral {
                
                peripheral.readValue(for: characteristic)
                print("[Server] 开始读取数据")
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let datas = characteristic.value {
        
            let str = String.init(data: datas, encoding: .utf8)
            
            if str == "S|" {
                
                self.pReceiveDataReader = CLTNNReceiveDataReader.init()
            }
            else if str == "|E" {
                
                self.pDelegate?.dgServer_ReceiveMsgFromClient(reader: self.pReceiveDataReader!)
            }
            else if datas.count > 0 {
                
                self.pReceiveDataReader?.pData.append(datas)
            }
        }   
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
}
