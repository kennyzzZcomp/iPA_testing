//
//  customButton.swift
//  AgvPlayer
//
//  Created by Huangzijian on 6/3/2025.
//

import SwiftUI

struct SideBarView: View {
    @Binding var isShowing: Bool  // 绑定到 ContentView 的控制变量

    var body: some View {
        VStack(alignment: .leading) {
            /*
            Button(action: {
                isShowing = false  // 关闭菜单
            }) {
                HStack {
                    Image(systemName: "xmark") // 关闭按钮
                    Text("关闭")
                }
                .padding()
            }*/

            //Divider()

            // **添加菜单项**
            NavigationLink(destination: Text("波形界面")) {
                HStack {
                    Image(systemName: "waveform.path.ecg") // 波形图标
                    Text("波形")
                }
                .padding()
                .foregroundColor(.black)
            }
            Divider()

            NavigationLink(destination: Text("参数设置")) {
                HStack {
                    Image(systemName: "gearshape") // 设置图标
                    Text("参数")
                }
                .padding()
                .foregroundColor(.black)
            }
            Divider()

            NavigationLink(destination: Text("调试模式")) {
                HStack {
                    Image(systemName: "ladybug") // 调试图标
                    Text("调试")
                }
                .padding()
                .foregroundColor(.black)
            }
            Divider()

            Spacer()
        }
        
    }
}




