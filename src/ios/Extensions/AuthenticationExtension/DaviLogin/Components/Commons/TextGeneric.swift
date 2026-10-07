//
//  Subtitule.swift
//  Davivienda
//
//  Created by Alejandro Lopez on 12/08/24.
//

import SwiftUI

struct TextGeneric: View {
    var text: String
    var size: CGFloat = 14
    var color: Color = Color.black800
    var bold: Bool = false
    
    var body: some View {
        if bold {
            Text(text).font(.custom("Roboto-Medium", size: size)).foregroundColor(color)
        } else {
            processText(text)
        }
    }
    
    private func processText(_ text: String) -> Text {
        let components = text.components(separatedBy: "*")
        var result: Text = Text("")
        
        for (index, component) in components.enumerated() {
            if index % 2 == 0 {
                // Normal text
                result = result + Text(component).font(.custom("Roboto-Regular", size: size)).foregroundColor(color)
            } else {
                // Bold text
                result = result + Text(component).font(.custom("Roboto-Medium", size: size)).foregroundColor(color)
            }
        }
        
        return result
    }
}

#Preview {
    TextGeneric(text: "*text* text", bold: true)
}
