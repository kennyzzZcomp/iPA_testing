//
//  CustomNavigationBar.swift
//  AgvPlayer
//
//  Created by Huangzijian on 7/3/2025.
//

import SwiftUI

struct CustomNavigationBar: View {
    var title: String
    var leadingButtonAction: () -> Void
    //var trailingButtonAction: () -> Void

    var body: some View {
        HStack {
            Button(action: leadingButtonAction) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            /*
            Spacer()
            Button(action: trailingButtonAction) {
                Image(systemName: "plus")
                    .foregroundColor(.blue)
            }*/
        }
        .padding()
        .background(Color.white)
        .shadow(color: .gray.opacity(0.5), radius: 2, x: 0, y: 2)
    }
}

