import SwiftUI

struct LoginActivity: View {
    @StateObject var viewModel = LoginViewModel()
    @EnvironmentObject var pagesViewModel : PagesViewModel
    
    @State private var username: String = const.EMPTY_STRING
    @State private var password: String = const.EMPTY_STRING
    @State private var isRegister: Bool = false
    @State private var isButtonDisabled: Bool = true
    
    var onLoginSuccess: ((String) -> Void)
    
    init(onLoginSuccess: @escaping ((String) -> Void)) {
            self.onLoginSuccess = onLoginSuccess
        }
    
    @State private var firstName: String = "Alejandro"
    
    var body: some View {
        GeometryReader { geo in
            let greeting = updateGreeting(name: false)
            let greetingName = updateGreeting(name: true)
            
            Image("image-login-bg")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.top)
                .frame(width: geo.size.width ,alignment: .topLeading)
            
            ZStack {
                VStack(spacing: 16){
                    VStack(alignment: .leading, spacing: 16) {
                        Image("icon-logo-davivienda-white")

                        TitleGeneric(
                            text: isRegister ? String(format: greetingName, firstName) : greeting,
                            size: 24,
                            color: Color.white
                        )
                    }
                    .padding([.top, .leading], 8)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    FormLogin(
                        username: $username,
                        password: $password,
                        showModal: $viewModel.isShowModal,
                        isRegister: $isRegister,
                        isButtonDisabled: $isButtonDisabled,
                        action: onClick,
                        biometricsAction: authenticateWithBiometrics
                    )
                    .environmentObject(viewModel)
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .frame(width: geo.size.width, height: geo.size.height-72)
            .onChange(of: viewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    
                }
            }
            
            if viewModel.isShowModal{
                ModalView(
                    icon: "icon-alert-circle",
                    title: viewModel.errorMessage ?? const.EMPTY_STRING,
                    buttonText: label.button.accept,
                    buttonAction: { viewModel.isShowModal = false }
                )
            }
        }
        .background(Color.white)
    }
    
    func onClick() {
        viewModel.authenticate(
            alias: username,
            pass: password,
            onSuccess: { token in
                onLoginSuccess(token)
            }
        )
    }
    
    func authenticateWithBiometrics() {
            viewModel.authenticateWithBiometrics()
        }
    
    func updateGreeting(name: Bool) -> String {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        switch currentHour {
        case 0..<12:
            return name ? label.login.greetingDayName : label.login.greetingDay
        case 12..<18:
            return name ? label.login.greetingAfeternoonName : label.login.greetingAfeternoon
        default:
            return name ? label.login.greetingNightName : label.login.greetingNight
        }
    }
}
#if DEBUG
struct LoginActivity_Previews: PreviewProvider {
    static var previews: some View {
        let pagesViewModel = PagesViewModel()
        return LoginActivity{_ in}
            .environmentObject(pagesViewModel)
    }
}

struct DummyLabels {
    struct Login {
        let greetingDay = "¡Buenos días!"
        let greetingDayName = "¡Buenos días, %@!"
        let greetingAfeternoon = "¡Buenas tardes!"
        let greetingAfeternoonName = "¡Buenas tardes, %@!"
        let greetingNight = "¡Buenas noches!"
        let greetingNightName = "¡Buenas noches, %@!"
    }
    struct Generic {
        let tyc = "Términos y Condiciones"
    }
    struct Button {
        let accept = "Aceptar"
    }
    let login = Login()
    let generic = Generic()
    let button = Button()
}
#endif



