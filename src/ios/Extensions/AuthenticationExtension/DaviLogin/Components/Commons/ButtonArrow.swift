//
//  ButtonArrow.swift
//  HelloWorldXcode
//
//  Created by Alejandro Lopez on 5/08/24.
//

import SwiftUI

struct ButtonArrow: View {
    var title: String = const.EMPTY_STRING
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                if title != const.EMPTY_STRING {
                    Text(title)
                        .font(.custom("Roboto-Medium", size: 14))
                }
                
                //Image("icon-arrow-right")
                Image("icon-arrow-right")
            }
            .foregroundColor(Color.black900)
        }
    }
}

#Preview {
    ButtonArrow(title: "title", action: {})
}
