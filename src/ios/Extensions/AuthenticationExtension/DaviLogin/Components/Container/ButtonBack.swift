//
//  ButtonBack.swift
//  Davivienda
//
//  Created by Alejandro Lopez on 21/08/24.
//

import SwiftUI

struct ButtonBack: View {
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 0){
            Image("icon-arrow-right")
                .renderingMode(.template)
                .rotationEffect(.degrees(180))
                .foregroundColor(Color.black900)
            TextGeneric(text: "Atrás", color: Color.black900)
        }
        .padding([.leading, .top], 16)
        .onTapGesture { action() }
    }
}

#Preview {
    ButtonBack(){}
}
