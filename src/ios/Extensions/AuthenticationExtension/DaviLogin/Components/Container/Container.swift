//
//  Container.swift
//  Davivienda
//
//  Created by Alejandro Lopez on 21/08/24.
//

import SwiftUI

struct Container<Content>: View where Content: View {
    let type: ContainerType
    var headerLeft: String = const.EMPTY_STRING
    var headerRight: String = const.EMPTY_STRING
    var headerCenter: String = const.EMPTY_STRING
    let content: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if (type == .home) { Header(type: .home, headerCenter: headerLeft) }
                if (type == .form) { Header(type: .form, headerLeft: headerLeft) }
                
                ZStack{
                    ScrollView{ content() }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .background(Color.gray300)
        }
    }
}


//#Preview {
//    Container()
//}
