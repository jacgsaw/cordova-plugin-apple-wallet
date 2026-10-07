//
//  ActionTitle.swift
//  HelloWorldXcode
//
//  Created by Alejandro Lopez on 5/08/24.
//

import SwiftUI

struct ActionTitle<Content: View>: View {
    var title: String
    var size: CGFloat = 16
    var color: Color = Color.black000
    var button: Content?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Roboto-Medium", size: size))
                .fontWeight(.bold)
                .foregroundColor(color)
            Spacer()
            button
        }
    }
}

#Preview {
    ActionTitle(title: "title", button: ButtonAdd(title: "Button", action: {}))
}
