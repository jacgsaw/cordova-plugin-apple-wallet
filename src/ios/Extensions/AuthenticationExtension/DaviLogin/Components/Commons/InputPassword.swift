import SwiftUI

struct InputPassword: View {
    var placeholder : String
    var maxLength : Int?
    @State var isVisible: Bool
    @Binding var state: String

    var body: some View {
        ZStack(alignment: .leading) {
            if state.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray900)
                    .padding(.leading, 8)
            }
            
            HStack {
                if isVisible {
                    TextField("", text: $state)
                        .foregroundColor(.black)
                        .padding(.leading, 8)
                } else {
                    SecureField("", text: $state)
                        .foregroundColor(.black800)
                        .padding(.leading, 8)
                }
                
                Button(action: {
                    isVisible.toggle()
                }) {
                    Image(isVisible ? "icon-eye" : "icon-eye-slash")
                        .foregroundColor(Color.gray)
                        .padding()
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
        .onChange(of: state) { newValue in
            if let maxLength = maxLength {
                state = String(newValue.prefix(maxLength))
            }
        }
    }
}

struct Preview_InputPassword: PreviewProvider {
    static var previews: some View {
        // Estados locales para los Bindings
        @State var state = ""
        @State var isVisible = false
        
        // Llamada a la vista con los estados locales
        return InputPassword(placeholder: "placeholder", isVisible: isVisible, state: $state)
    }
}
