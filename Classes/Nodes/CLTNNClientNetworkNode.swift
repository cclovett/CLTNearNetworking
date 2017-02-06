//
//  CLTNNClientNetworkNode.swift
//  CLTNearNetworking
//
//  Created by Cc on 2017/2/5.
//  Copyright © 2017年 Cc. All rights reserved.
//

import UIKit

public class CLTNNClientNetworkNode: CLTNNNetworkNode {

//    private lazy var pArrDataPackages = NSMutableArray.init()
//    private var pSendDataWriter: CLTNNSendDataWriter? = nil
    
    public func fStartConnecting() {
        // 子类实现
        assert(false)
    }
    
    public func fStopConnecting() {
        // 子类实现
        assert(false)
    }
    
    
//    func fBeginMessageIdentifier(identifier: Int) -> CLTNNSendDataWriter {
//        
//        self.pSendDataWriter = CLTNNSendDataWriter.init()
//        self.pSendDataWriter?.fWriteInt(identifier)
//        return self.pSendDataWriter!
//        return self.fBeginMsgToSendWithIdentifier(identifier: identifier)
//    }
//    func fEndMessage() {
//        
//        self.pArrDataPackages .add(self.pSendDataWriter!)
//        self.pSendDataWriter = nil
//        self.fSendAllMsg();
//    }
    
    
//    func fSendAllMsg() {
//        
//        if self.pArrDataPackages.count > 0 {
//            
//            let tmpW = self.pArrDataPackages.firstObject as? CLTNNSendDataWriter
//            if let writer = tmpW {
//                
//                if writer.pSendState == .eInit {
//                    
//                    writer.pSendState = .eBeginSendHead
//                    self.fOnSendMsgToServer(writer: writer)
//                }
//                else if (writer.pSendState == .eSendEnd) {
//                    
//                    self.pArrDataPackages .remove(writer)
//                    self.fSendAllMsg()
//                }
//            }
//        }
//    }
//    func fOnSendMsgToServer(writer: CLTNNSendDataWriter) {
//        
//        // 子类实现
//        assert(false)
//    }
}
