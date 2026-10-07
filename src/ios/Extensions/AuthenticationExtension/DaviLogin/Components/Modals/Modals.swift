//
//  DaviButton.swift
//  Davivienda
//
//  Created by Jose Cruz on 4/08/24.
//

import SwiftUI

struct ModalView: View {
    var icon: String
    var title: String
    var message: String = const.EMPTY_STRING
    var buttonText: String
    var buttonAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
            .edgesIgnoringSafeArea(.all)
            
            VStack() {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.red)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                
                Text(title)
                    .font(.custom("Roboto-Bold", size: 16))
                    .foregroundColor(Color.black)
                    .padding(.top, 8)
                
                if (message != const.EMPTY_STRING) {
                    Text(message)
                        .font(.custom("Roboto-Regular", size: 12))
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                        .padding([.top, .bottom], 8)
                        .padding(.horizontal, 20)
                }
                
                Button(action: {
                    buttonAction()
                }) {
                    Text(buttonText)
                        .font(.custom("Roboto-Medium", size: 14))
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 216, height: 40)
                        .background(Color.red000)
                        .foregroundColor(Color.white)
                        .cornerRadius(20.0)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.top, .bottom], 16)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 40)
        }
    }
}
