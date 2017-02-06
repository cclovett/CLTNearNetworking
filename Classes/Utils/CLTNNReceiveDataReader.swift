//
//  CLTNNReceiveDataReader.swift
//  CLTNearNetworking
//
//  Created by Cc on 2017/2/5.
//  Copyright © 2017年 Cc. All rights reserved.
//

import UIKit

public class CLTNNReceiveDataReader: NSObject {

    lazy var pData = NSMutableData.init()
    private lazy var pReadDataIndex: Int = 0
    
    public func fReadInt() -> Int {
        
        var range = NSRange.init()
        range.location = self.pReadDataIndex;
        range.length = MemoryLayout.size(ofValue: Int.init())
        self.pReadDataIndex += range.length
        var i: Int = 0
        self.pData .getBytes(&i, range: range)
        return i
    }
    
    public func fReadString() -> String {
        
        let lenght = self.fReadInt()
        let range = NSRange.init(location: self.pReadDataIndex, length: lenght)
        let chunk = Data.init(bytes: self.pData.bytes + self.pReadDataIndex, count: range.length)
        let str = String.init(data: chunk, encoding: String.Encoding.utf8)
        return str!
    }
}
