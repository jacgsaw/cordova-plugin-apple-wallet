import SwiftUI
import LocalAuthentication

struct FormLogin: View {
    @Binding var username : String
    @Binding var password : String
    @Binding var showModal : Bool
    @Binding var isRegister: Bool
    @Binding var isButtonDisabled : Bool
    
    var action: () -> Void
    var biometricsAction: () -> Void
    
    @State private var isFaceID: Bool = true
    @State private var isBiometryOn: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !isRegister {
                TextGeneric(text: label.login.enterUsername, bold: true)
                
                InputText(placeholder: "Usuario", maxLength: 10, state: $username)
                    .onChange(of: username) { newValue in
                        username = validateUsernameAndPassword(key: "user", value: username)
                    }
            }
            
            TextGeneric(text: label.login.enterPassword, bold: true)
            
            InputPassword(placeholder: "Clave virtual", maxLength: 30, isVisible: isPasswordVisible, state: $password)
                .onChange(of: password) { newValue in
                    password = validateUsernameAndPassword(key: "pass", value: password)
                }
            
            HStack(spacing: 0) {
                Spacer()
                ButtonGeneric(label: label.button.login, disable: isButtonDisabled, width: 240, action: action)
                Spacer()

                if isRegister && isBiometryOn {
                    Button(action: biometricsAction) {
                        Image(isFaceID ? "icon-button-face-id" : "icon-button-fingerprint")
                            .padding(.leading, 8)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            if (isRegister) {
                VStack(spacing: 16) {
                    Separator()
                    ActionTitle(title: "Iniciar sesión con otro usuario", size: 12, color: Color.black800, button: ButtonArrow(){})
                        .frame(height: 24)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .onAppear {
            checkBiometryType()
        }
    }
    
    // Detectar el tipo de biometria del dispositivo
    func checkBiometryType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometryOn = true
            switch context.biometryType {
            case .faceID:
                isFaceID = true
            case .touchID:
                isFaceID = false
            default:
                isFaceID = false
            }
        } else {
            isBiometryOn = false
        }
    }
    
    func buttonDisabled(){
        if isRegister ? password.count > 7 : username.count > 3 && password.count > 7 {
            isButtonDisabled = false
        } else {
            isButtonDisabled = true
        }
    }
    
    func validateUsernameAndPassword(key: String, value: String) -> String {
        let pattern = key == "user" ? const.REGEX_USERNAME : const.REGEX_PASSWORD
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: value.utf16.count)
        if regex.firstMatch(in: value, options: [], range: range) == nil {
            return String(value.dropLast())
        }

        buttonDisabled()
        
        return value
    }
}


#if DEBUG

struct Preview_FormLogin: PreviewProvider {
    static var previews: some View {
        // Estados locales para los Bindings
        @State var username = ""
        @State var password = ""
        @State var showModal = false
        @State var isRegister = false
        @State var isButtonDisabled = true

        return FormLogin(
            username: $username,
            password: $password,
            showModal: $showModal,
            isRegister: $isRegister,
            isButtonDisabled: $isButtonDisabled,
            action: {},
            biometricsAction: {}
        )
    }
}
#endif
