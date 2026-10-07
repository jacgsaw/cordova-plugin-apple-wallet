//
//  ButtonTab.swift
//  HelloWorldXcode
//
//  Created by Alejandro Lopez on 5/08/24.
//

import SwiftUI

fileprivate struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.custom("Roboto-Medium", size: 14))
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundColor(isSelected ? .black : Color.black600)
                    .frame(height: 16)
                    .padding([.top, .horizontal], 16)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ButtonTab<LeftContent: View, RightContent: View>: View {
    @State private var selectedTab = "1"
    
    var text1: String
    var text2: String
    var bodyLeft: LeftContent
    var bodyRight: RightContent
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack {
                TabButton(title: text1, isSelected: selectedTab == "1") {
                    selectedTab = "1"
                }
                TabButton(title: text2, isSelected: selectedTab == "2") {
                    selectedTab = "2"
                }
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 0) {
                Rectangle()
                    .frame(height: selectedTab == "1" ? 4 : 2)
                    .foregroundColor(selectedTab == "1" ? Color.red600 : Color.black200)
                    .animation(.default, value: selectedTab)
                    .cornerRadius(2)
                Rectangle()
                    .frame(height: selectedTab == "2" ? 4 : 2)
                    .foregroundColor(selectedTab == "2" ? Color.red600 : Color.black200)
                    .animation(.default, value: selectedTab)
                    .cornerRadius(2)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            if selectedTab == "1" {bodyLeft} else {bodyRight}
        }
    }
}

#Preview {
    ButtonTab(text1: "Text1", text2: "Text2", bodyLeft: EmptyView(), bodyRight: EmptyView())
}
