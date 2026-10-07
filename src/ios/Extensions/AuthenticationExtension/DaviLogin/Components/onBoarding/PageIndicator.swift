//
//  PageIndicator.swift
//  Davivienda
//
//  Created by Alejandro Lopez on 13/08/24.
//

import SwiftUI

struct PageIndicator: View {
    var currentPage: Int = 0
    let totalPages: Int = 5

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                if index == currentPage {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red000)
                        .frame(width: 16, height: 6)
                } else {
                    Circle()
                        .fill(Color.black200)
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

#Preview {
    PageIndicator()
}
