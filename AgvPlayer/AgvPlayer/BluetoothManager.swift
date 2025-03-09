//
//  BluetoothManager.swift
//  AgvPlayer
//
//  Created by Huangzijian on 8/3/2025.
//

import Foundation
import CoreBluetooth
import SwiftUI

class BluetoothManager: NSObject, ObservableObject {
    // 发布属性，便于 SwiftUI 界面绑定更新
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral? = nil
    let serviceUUID = CBUUID(string: "0000FFE0-0000-1000-8000-00805F9B34FB")
    let notifyCharacteristicUUID = CBUUID(string: "0000FFE1-0000-1000-8000-00805F9B34FB")
    let writeCharacteristicUUID = CBUUID(string: "0000FFE2-0000-1000-8000-00805F9B34FB")

    
    // 中心管理器
    private var centralManager: CBCentralManager!
    var commandCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        // 初始化 CBCentralManager，并指定代理为 self
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    

}

extension BluetoothManager: CBCentralManagerDelegate {
    // 蓝牙状态更新
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        switch central.state {
        case .poweredOn:
            print("蓝牙已开启")
        case .poweredOff:
            print("蓝牙已关闭")
        default:
            print("蓝牙状态改变：\(central.state)")
        }
    }
    
    // 扫描到设备时回调
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        // 避免重复添加同一设备
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
        print("发现设备：\(peripheral.name ?? "无名设备")")
    }
    
    // 连接成功回调
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("连接到设备：\(peripheral.name ?? "无名设备")")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        // 发现外围设备的所有服务
        peripheral.discoverServices(nil)
    }
    
    // 连接失败回调
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接设备失败：\(error?.localizedDescription ?? "未知错误")")
    }
    
    // 断开连接回调
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("设备断开：\(peripheral.name ?? "无名设备")")
        if connectedPeripheral == peripheral {
            connectedPeripheral = nil
        }
    }

}

extension BluetoothManager: CBPeripheralDelegate {
    // 发现服务后回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("发现服务：\(service.uuid)")
                // 发现服务后，可以进一步发现特征
                if service.uuid == serviceUUID {
                    peripheral.discoverCharacteristics([notifyCharacteristicUUID, writeCharacteristicUUID], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                switch characteristic.uuid {
                case notifyCharacteristicUUID:
                    print("发现通知特征：\(characteristic.uuid)")
                    // 开启通知
                    peripheral.setNotifyValue(true, for: characteristic)

                case writeCharacteristicUUID:
                    print("发现写入特征：\(characteristic.uuid)")
                    // 保存到 commandCharacteristic，方便后续写入
                    self.commandCharacteristic = characteristic

                default:
                    break
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard error == nil else {
            print("更新特征值时出错: \(error!.localizedDescription)")
            return
        }

        if characteristic.uuid == notifyCharacteristicUUID {
            if let data = characteristic.value {
                // 处理接收到的数据
                print("收到通知数据：\(data as NSData)")
                // 可根据协议解析 data
            }
        }
    }

    
}

// MARK: - 公共方法
extension BluetoothManager {
    // 开始扫描设备
    func startScan() {
        guard centralManager.state == .poweredOn else {
            print("蓝牙未开启")
            return
        }
        discoveredPeripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("开始扫描...")
    }
    
    // 停止扫描设备
    func stopScan() {
        centralManager.stopScan()
        print("停止扫描")
    }
    
    // 连接指定设备
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    // 断开连接
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    //发送命令
    func sendCommand(_ command: UInt8) {
        guard let peripheral = connectedPeripheral,
              let characteristic = commandCharacteristic else {
            print("未连接或未获取到写入特征")
            return
        }
        let data = Data([command])
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        print("发送命令：\(command)")
    }
    
}


    // 其余属性和方法省略或模拟...




