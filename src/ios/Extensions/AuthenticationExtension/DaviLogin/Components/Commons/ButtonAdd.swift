//
//  ButtonAdd.swift
//  HelloWorldXcode
//
//  Created by Alejandro Lopez on 2/08/24.
//

import SwiftUI

struct ButtonAdd: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Circle()
                .fill(Color.white)
                .frame(width: 32, height: 32)
                .overlay(Image("icon-add").resizable().scaledToFit().frame(width: 22))
                .overlay(Circle().stroke(Color.gray100, lineWidth: 1))
            Text(title)
                .font(.custom("Roboto-Medium", size: 11))
                .foregroundColor(Color.black)
                .frame(height: 32)
                .padding(.trailing, 16)
        }
        .background(Color.white)
        .cornerRadius(20.0)
    }
}

#Preview {
    ButtonAdd(title: "title"){}
}
