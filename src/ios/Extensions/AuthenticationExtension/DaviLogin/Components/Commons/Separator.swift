import SwiftUI

struct Separator: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color.black200)
    }
}

#Preview {
    Separator()
}
