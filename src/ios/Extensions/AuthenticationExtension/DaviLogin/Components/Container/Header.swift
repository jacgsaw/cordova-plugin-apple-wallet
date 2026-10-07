//
//  Header.swift
//  Davivienda
//
//  Created by Alejandro Lopez on 21/08/24.
//

import SwiftUI

struct Header: View {
    var type: HeaderType
    var headerLeft: String = const.EMPTY_STRING
    var headerRight: String = "icon-header-close"
    var headerCenter: String = "icon-logo-davivienda-white"
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if type == .home {
                    Image("icon-user-header").resizable().scaledToFit().frame(width: 32, height: 32).padding(.leading, 8).onTapGesture {print("iconHeader")}
                    Spacer()
                    TitleGeneric(text: headerCenter, size: 16, color: Color.white)
                    Spacer()
                    Rectangle().frame(width: 32, height: 32).foregroundStyle(.clear).padding(.trailing, 8)
                } else if type == .form {
                    TitleGeneric(text: headerLeft, size: 16, color: Color.white)
                        .padding(.leading, 8)
                    Spacer()
                    Image(headerRight)
                } else if type == .login {
                    Rectangle().frame(width: 24, height: 24).foregroundStyle(.clear)
                    Spacer()
                    Image(headerCenter)
                    Spacer()
                    Image(headerRight)
                } else if type == .visual {
                    TitleGeneric(text: headerLeft, size: 16, color: Color.white)
                        .padding(.leading, 8)
                    Spacer()
                } else if type == .result {
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Image("icon-header-close").resizable().scaledToFit().frame(width: 32, height: 32)
                            Spacer()
                            
                                Image("icon-header-close").resizable().scaledToFit().frame(width: 32, height: 32)
                        }
                        .padding(.top, 24)
                        TitleGeneric(text: headerCenter, size: 22, color: Color.white)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                
            }
            .padding(.horizontal, 16)
        }
        .frame(height: type == .home ? 72 : type == .result ? 360 : 88)
        .background(
            LinearGradient(gradient: Gradients.gradient01, startPoint: .leading, endPoint: .trailing)
                .edgesIgnoringSafeArea(.top)
        )
    }
}

#Preview {
    Header(type: .home)
}
