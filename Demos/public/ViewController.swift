//
//  ViewController.swift
//  DemoNN
//
//  Created by Cc on 2017/2/5.
//  Copyright © 2017年 Cc. All rights reserved.
//

import UIKit
//import CLTNearNetworking
import CoreBluetooth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

let kServiceUUID = CBUUID.init(string: "54CC24BA-4445-4F12-A7D7-9EE7F25C573E")
let kCharacteristicUUID = CBUUID.init(string: "9B34BC05-E819-49DE-84B9-DC8B17DE0692")

class ServerVC: UIViewController, CLTNNNetworkNodeDelegate {
    
    var server: CLTNNBluetoothServerService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height: 100)
        btn.setTitle("send", for: UIControlState.normal)
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(self.onClick(_:)), for: UIControlEvents.touchUpInside)
        
        self.server = CLTNNBluetoothServerService.init(serviceUUID: kServiceUUID, characteristicUUID: kCharacteristicUUID, maxConnections: 1)
        self.server?.pDelegate = self
        self.server?.fStartListening()
    }
    
    func dgClient_EndSendMsgToServer(writer: CLTNNSendDataWriter) {
        
    }
    func dgServer_ReceiveMsgFromClient(reader: CLTNNReceiveDataReader) {
        
    }
    func dgNode_Connected() {
        
        print("Server 连接成功")
    }
    

    func onClick(_ sender: Any) {
        
        self.server?.fBeginMsg(identifier: 1, block: { (writer: CLTNNSendDataWriter) in
            writer.fWriteString("123")
        })
    }
}

class ClientVC: UIViewController, CLTNNNetworkNodeDelegate {
    
    var client: CLTNNBluetoothClientService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height: 100)
        btn.setTitle("send", for: UIControlState.normal)
        self.view.addSubview(btn)
        btn.addTarget(self, action: #selector(self.onClick(_:)), for: UIControlEvents.touchUpInside)
        
        
        
        self.client = CLTNNBluetoothClientService.init(serviceUUID: kServiceUUID, characteristicUUID: kCharacteristicUUID)
        self.client?.pDelegate = self
        self.client?.fStartConnecting()
    }
    
    func dgClient_EndSendMsgToServer(writer: CLTNNSendDataWriter) {
        
    }
    func dgServer_ReceiveMsgFromClient(reader: CLTNNReceiveDataReader) {
        
    }
    func dgNode_Connected() {
        
        print("Client 连接成功")
    }
    
    func onClick(_ sender: Any) {
        
        self.client?.fBeginMsg(identifier: 2, block: { (writer: CLTNNSendDataWriter) in
            writer.fWriteString("33333")
        })
        
    }
}
