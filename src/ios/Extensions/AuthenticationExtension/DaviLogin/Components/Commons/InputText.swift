import SwiftUI

struct InputText: View {
    var placeholder : String
    var maxLength : Int?
    @Binding var state: String

    var body: some View {
        ZStack(alignment: .leading) {
            if state == const.EMPTY_STRING {
                Text(placeholder)
                    .foregroundColor(.gray900)
                    .padding(.leading, 8)
            }

            TextField(const.EMPTY_STRING, text: $state)
                .foregroundColor(.black800)
                .padding(.leading, 8)
                .onChange(of: state) { newValue in
                    if let maxLength = maxLength {
                        state = String(newValue.prefix(maxLength))
                    }
                }
        }
        .font(.custom("Roboto-Regular", size: 16))
        .frame(height: 40)
        .background(Color.white)
        .cornerRadius(8.0)
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .overlay(
            RoundedRectangle(cornerRadius: 8.0)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}


struct Preview_InputText: PreviewProvider {
    static var previews: some View {
        // Estados locales para los Bindings
        @State var state = const.EMPTY_STRING
        
        // Llamada a la vista con los estados locales
        return InputText(placeholder: "Usuario", maxLength: 10, state: $state)
    }
}
