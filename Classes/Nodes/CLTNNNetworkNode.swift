//
//  CLTNNNetworkNode.swift
//  CLTNearNetworking
//
//  Created by Cc on 2017/2/5.
//  Copyright © 2017年 Cc. All rights reserved.
//

import UIKit

public protocol CLTNNNetworkNodeDelegate: NSObjectProtocol {
    
    func dgClient_EndSendMsgToServer(writer: CLTNNSendDataWriter)
    
    func dgServer_ReceiveMsgFromClient(reader: CLTNNReceiveDataReader)
    
    
    func dgNode_Connected()
//    optional
    
}

public class CLTNNNetworkNode: NSObject {

    public weak var  pDelegate: CLTNNNetworkNodeDelegate?
    
    private lazy var pArrDataPackages = NSMutableArray.init()
//    var pSendDataWriter: CLTNNSendDataWriter? = nil
//    var pReceiveDataReader: CLTNNReceiveDataReader? = nil

    public func fBeginMsg(identifier: Int, block: (_ writer: CLTNNSendDataWriter)->Void) {
        
        let wri = CLTNNSendDataWriter.init()
        wri.fWriteInt(identifier)
        block(wri)
        self.pArrDataPackages.add(wri)
    }
    
    func fSendAllMsg() {
        
        if self.pArrDataPackages.count > 0 {
            
            let tmpW = self.pArrDataPackages.firstObject as? CLTNNSendDataWriter
            if let writer = tmpW {
                
                if writer.pSendState == .eInit {
                    
                    writer.pSendState = .eBeginSendHead
                    self.fOnSendMsgToOther(writer: writer)
                }
                else if (writer.pSendState == .eSendEnd) {
                    
                    self.pArrDataPackages.remove(writer)
                    self.fSendAllMsg()
                }
            }
        }
    }
    
    func fOnSendMsgToOther(writer: CLTNNSendDataWriter) {
        
        // 子类实现
        assert(false)
    }
}

