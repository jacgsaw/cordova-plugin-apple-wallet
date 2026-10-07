//
//  BottomNavigationExternalView.swift
//  Davivienda
//
//  Created by Alejandro Lopez on 14/08/24.
//

import SwiftUI

struct BottomNavigationExternalView: View {
    let options: [bottomNavigationExternalItemsType] = [
        bottomNavigationExternalItemsType (icon: "icon-exchange", label: "Tipo de cambio"),
        bottomNavigationExternalItemsType (icon: "icon-attention-points", label: "Puntos de atención"),
        bottomNavigationExternalItemsType (icon: "icon-search-house", label: "Venta de bienes"),
        bottomNavigationExternalItemsType (icon: "icon-more", label: "Más")
    ]
    
    var body: some View {
//        VStack {
//            Spacer()
//            
//            Rectangle()
//                .fill(.white)
//                .cornerRadius(16)
//                .edgesIgnoringSafeArea(.bottom)
//        }
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0)  {
                HStack(spacing: 0)  {
                    ForEach(options.indices, id: \.self) { index in
                        let item = options[index]

                        Button(action: {
                            
                        }) {
                            ButtonBottomNavigationExternal(
                                icon: item.icon,
                                label: item.label
                            ){}
                        }
                        
                        if index < options.count - 1 { Spacer() }
                    }
                }
                .frame(height: 72)
                .padding(.horizontal,
                    options.count == 5 ? 16 :
                    options.count == 4 ? 24 :
                    options.count == 3 ? 48 : 88
                )
            }
            .cornerRadius(16)
        }
    }
}

struct bottomNavigationExternalItemsType {
    let icon: String
    let label: String
}

struct ButtonBottomNavigationExternal: View {
    let icon   : String
    let label  : String
    let action : () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 0) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                Text(label)
                    .font(.custom("Roboto-Regular", size: 12))
                    .foregroundColor(Color.black600)
                    .frame(width: 64, height: 32)
                    .lineSpacing(0.0)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 64)
        }
        
    }
}

#Preview {
    BottomNavigationExternalView()
}
