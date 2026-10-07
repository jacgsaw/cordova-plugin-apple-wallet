//
//  Button.swift
//  HelloWorldXcode
//
//  Created by Alejandro Lopez on 6/08/24.
//

import SwiftUI

struct ButtonGeneric: View {
    var label: String
    var disable: Bool = false
    var type: ButtonType = .primary
    var width: CGFloat = 216
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            if type == .primary {
                VStack {
                    Text(label)
                        .font(.custom("Roboto-Bold", size: 14))
                        .foregroundColor(disable ? Color.black500 : Color.white)
                        .padding(.horizontal, 16)
                }
                .frame(width: width, height: 40)
                .background(disable ? Color.black200 : Color.red000)
                .cornerRadius(20.0)
                
            } else if type == .outline {
                VStack {
                    Text(label)
                        .font(.custom("Roboto-Bold", size: 14))
                        .foregroundColor(disable ? Color.black400 : Color.black800)
                        .padding(.horizontal, 16)
                }
                .frame(width: width, height: 40)
                .background(disable ? Color.black400 : Color.clear)
                .cornerRadius(20.0)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(disable ? Color.clear : Color.black800, lineWidth: 1))
            } else if type == .crystal {
                VStack {
                    Text(label)
                        .font(.custom("Roboto-Bold", size: 14))
                        .foregroundColor(disable ? Color.black400 : Color.black800)
                        .padding(.horizontal, 16)
                }
                .frame(width: width, height: 40)
                .background(disable ? Color.black400 : Color.clear)
                .cornerRadius(20.0)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 1))
            }
        }
        .disabled(disable)
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ButtonGeneric(label: "Type Something", disable: false) {}
}
