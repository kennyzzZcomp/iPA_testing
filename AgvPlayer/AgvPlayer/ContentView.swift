import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @State private var isShowingSidebar = false
    @State private var isConnected = false
    @ObservedObject var bluetoothManager = BluetoothManager()
    @State private var inputText: String = ""
   
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                // 自定义导航栏
                CustomNavigationBar(
                    title: "HOME",
                    leadingButtonAction: {
                        isShowingSidebar.toggle()
                    }
                )
                .offset(y: 15)
                
                
                    // 蓝牙操作按钮及状态显示
                    VStack(spacing: 10) {
                        HStack(spacing: 20) {
                            Button(action: {
                                bluetoothManager.startScan()
                                // 启动扫描后这里设置连接状态仅用于示例（实际连接以设备列表中的操作为准）
                                isConnected = true
                            }) {
                                Text("开始扫描")
                                    .padding()
                                    .frame(width: 200)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 3)
                                    )
                            }
                            
                            Button(action: {
                                bluetoothManager.stopScan()
                                isConnected = false
                            }) {
                                Text("停止")
                                    .padding()
                                    .frame(width: 100)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 3)
                                    )
                            }
                        }
                        
                        // 显示蓝牙状态
                        Text("蓝牙状态：\(stateDescription(bluetoothManager.bluetoothState))")
                            .padding(.horizontal, 8)
                        /**/
                        // 使用 ScrollView 和 LazyVStack 来构建可滚动的设备列表
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                                    HStack {
                                        Text(peripheral.name ?? "无名设备")
                                        Spacer()
                                        if bluetoothManager.connectedPeripheral == peripheral {
                                            HStack(spacing: 4) {
                                                Text("已连接")
                                                    .foregroundColor(.green)
                                                // 小按钮表示断开连接
                                                Button(action: {
                                                    bluetoothManager.disconnect()
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                        } else {
                                            Button("连接") {
                                                bluetoothManager.connect(to: peripheral)
                                            }
                                            .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .frame(height: 150)
                        .border(Color.gray, width: 1) // 如果需要边框可加此行
                        
                        GroupBox(label: Text("控制面板").font(.headline)) {
                            VStack(spacing: 16) {
                                Button(action: {
                                    // 前进操作
                                    bluetoothManager.sendCommand(1)
                                }) {
                                    Text("前进")
                                        .padding()
                                        .frame(width: 200)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.blue, lineWidth: 3)
                                        )
                                }
                                
                                Button(action: {
                                    // 停止操作
                                    bluetoothManager.sendCommand(0)
                                }) {
                                    Text("停止")
                                        .padding()
                                        .frame(width: 200)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.blue, lineWidth: 3)
                                        )
                                }
                                
                                Button(action: {
                                    // 掉头操作
                                    bluetoothManager.sendCommand(2)
                                }) {
                                    Text("掉头")
                                        .padding()
                                        .frame(width: 200)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.blue, lineWidth: 3)
                                        )
                                }
                            }
                            .padding()
                        }
                        GroupBox(label: Text("发送指令").font(.headline)){
                            // 带有占位符的文本框
                            TextField("请输入内容", text: $inputText)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                        // 显示当前输入的文本
                                        //Text("当前输入：\(inputText)")
                            
                            Button(action: {
                                if let commandValue = UInt8(inputText) {
                                    bluetoothManager.sendCommand(commandValue)
                                } else {
                                    //转换无效
                                    print("转换无效")
                                }
                            }) {
                                Text("发送")
                                .frame(width: 200)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                            }
                        }
                        
                        
                    }
                    .padding()
                
                
                
                
                Spacer()
            }
            .background(Color.clear)
            
            // 侧边栏视图
            if isShowingSidebar {
                SideBarView(isShowing: $isShowingSidebar)
                    .frame(width: 300, height: 650)
                    .offset(x: 0, y: 50)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 3)
                    )
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut, value: isShowingSidebar)
            }
        }
    }
    
    // 将 CBManagerState 转换成可读字符串
    private func stateDescription(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "未知"
        case .resetting:
            return "重置中"
        case .unsupported:
            return "不支持"
        case .unauthorized:
            return "未授权"
        case .poweredOff:
            return "已关闭"
        case .poweredOn:
            return "已开启"
        @unknown default:
            return "未知错误"
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

