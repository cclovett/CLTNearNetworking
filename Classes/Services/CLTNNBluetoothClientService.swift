//
//  CLTNNBluetoothClientService.swift
//  CLTNearNetworking
//
//  Created by Cc on 2017/2/5.
//  Copyright © 2017年 Cc. All rights reserved.
//

import UIKit
import CoreBluetooth

public class CLTNNBluetoothClientService: CLTNNClientNetworkNode {

    fileprivate let pCharacteristicUUID: CBUUID
    fileprivate let pServiceUUID: CBUUID
    
    fileprivate var pPeripheralManager: CBPeripheralManager? = nil
    fileprivate var pMutableCharacteristic:CBMutableCharacteristic? = nil
    
    fileprivate var pSendDataWriter: CLTNNSendDataWriter? = nil
    
    public init(serviceUUID: CBUUID, characteristicUUID: CBUUID) {
        
        self.pServiceUUID = serviceUUID
        self.pCharacteristicUUID = characteristicUUID
        
        super.init()
    }
    
    deinit {
        
        self.fReleaseBluetoothClient()
    }
    
    func fInitBluetoothClient() {
        
        if self.pPeripheralManager == nil {
            
            self.pPeripheralManager = CBPeripheralManager.init(delegate: self, queue: nil)
        }
    }
    
    func fReleaseBluetoothClient() {
        
        if self.pPeripheralManager != nil {
            
            self.pPeripheralManager?.stopAdvertising()
            self.pPeripheralManager?.delegate = nil
            self.pPeripheralManager = nil
            
            self.pMutableCharacteristic = nil
        }
    }
    
    func fInitMutableCharacteristic() {
        
        if self.pMutableCharacteristic == nil {
            
            self.pMutableCharacteristic = CBMutableCharacteristic.init(type: self.pCharacteristicUUID, properties: CBCharacteristicProperties.notify, value: nil, permissions: CBAttributePermissions.readEncryptionRequired)
            
            let customService = CBMutableService.init(type: self.pServiceUUID, primary: true)
            customService.characteristics = [self.pMutableCharacteristic!]
            
            self.pPeripheralManager?.add(customService)
        }
    }
    
    override public func fStartConnecting() {
        
        self.fInitBluetoothClient()
    }
    
    override public func fStopConnecting() {
        
        self.fReleaseBluetoothClient()
    }
    
    func fSendStartDataMsg() {
        
        if self.pSendDataWriter?.pSendState == .eBeginSendHead {
           
            let sData = "S|".data(using: String.Encoding.utf8)!
            let didSend = self.pPeripheralManager?.updateValue(sData, for: self.pMutableCharacteristic!, onSubscribedCentrals: nil)
            if didSend == true {
                
                self.pSendDataWriter?.pSendState = .eBeginSendBody
            }
        }
    }
    
    func fSendEndDataMsg() {
        
        if self.pSendDataWriter?.pSendState == .eBeginSendEnd {
            
            let sData = "|E".data(using: String.Encoding.utf8)!
            let didSend = self.pPeripheralManager?.updateValue(sData, for: self.pMutableCharacteristic!, onSubscribedCentrals: nil)
            if didSend != nil {
                
                self.pSendDataWriter?.pSendState = .eSendEnd
                self.pDelegate?.dgClient_EndSendMsgToServer(writer: self.pSendDataWriter!)
            }
        }
    }
    
    override func fOnSendMsgToOther(writer data: CLTNNSendDataWriter) {
        
        self.fSendData()
    }
    
    func fSendData() {
        
        if self.pSendDataWriter == nil {
            
            return
        }
        
        self.fSendStartDataMsg()
        
        // send body
        if self.pSendDataWriter!.pSendState == .eBeginSendBody {
            // There's data left, so send until the callback fails, or we're done.
            var didSend = true
            while didSend {
                // Work out how big it should be
                var amountToSend = self.pSendDataWriter!.pData.length - self.pSendDataWriter!.pSendDataIndex
                // Can't be longer than 20 bytes
                if amountToSend > 20 {
                    
                    amountToSend = 20
                }
                // Copy out the data we want
                let chunk = Data.init(bytes: self.pSendDataWriter!.pData.bytes + self.pSendDataWriter!.pSendDataIndex, count: amountToSend)
                
                didSend = self.pPeripheralManager!.updateValue(chunk, for: self.pMutableCharacteristic!, onSubscribedCentrals: nil)
                // If it didn't work, drop out and wait for the callback
                if !didSend {
                    
                    return
                }
                // It did send, so update our index
                self.pSendDataWriter!.pSendDataIndex += amountToSend
                
                // We're sending data
                // Is there any left to send?
                if self.pSendDataWriter!.pSendDataIndex >= self.pSendDataWriter!.pData.length {
                    // No data left.  Do nothing
                    self.pSendDataWriter!.pSendState = .eBeginSendEnd
                    self.fSendEndDataMsg()
                    return
                }
            }
        }
    }
}


// MARK: - 连接回调
extension CLTNNBluetoothClientService: CBPeripheralManagerDelegate {
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    
        switch peripheral.state {
        case .poweredOn:
            self.fInitMutableCharacteristic()
        default:
            print("[Client] 此设备不支持 BLE 4.0")
            break
        }
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        if error != nil {
            
            print("[Client] peripheralManager:didAddService:error :\(error)")
        }
        else {
            
            self.pPeripheralManager?.startAdvertising([
                CBAdvertisementDataLocalNameKey:"ICServer"
                , CBAdvertisementDataServiceUUIDsKey: [self.pServiceUUID]
                ])
        }
    }
    
    // 有设备连接
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        print("[Client] didSubscribeToCharacteristic 发现设备连接")
        self.pDelegate?.dgNode_Connected()
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        print("[Client] 意外退出连接 didUnsubscribeFromCharacteristic")
    }
    
    public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        
        self.fSendData()
        print("[Client] 连接 toUpdateSubscribers")
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        print("[Client] 开始 advertising")
    }
    
    
}
