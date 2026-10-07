import SwiftUI

struct TitleGeneric: View {
    var text: String
    var size: CGFloat = 22
    var color: Color = Color.black000
    
    var body: some View {
        Text(text)
            .font(.custom("Roboto-Bold", size: size))
            .foregroundColor(color)
    }
}

#Preview {
    TitleGeneric(text: "Titulo")
}
