//
//  DaviButton.swift
//  Davivienda
//
//  Created by Jose Cruz on 4/08/24.
//

import SwiftUI

struct DaviButton: View {
    var isButtonDisabled: Bool
    var textButton: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(textButton)
                .font(.custom("Roboto-Medium", size: 14))
                .fontWeight(.bold)
                .padding()
                .frame(width: 216, height: 40)
                .background(isButtonDisabled ? Color.gray000 : Color.red000)
                .foregroundColor(isButtonDisabled ? Color.gray : Color.white)
                .cornerRadius(20.0)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 10)
        .disabled(isButtonDisabled)
    }
}

