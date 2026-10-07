//
//  LoginViewModel.swift
//  Davivienda
//
//  Created by Jose Cruz on 6/08/24.
//

import Foundation
import LocalAuthentication
import Security


final class LoginViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var tokenResponse: TokenResponse?
    @Published var errorMessage: String?
    @Published var isShowModal = false
    
    var sessionId: String?
    var authenticationSchemaId: String?
    
    private let headerApi = API.Header.self
    
    func formURLEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._*")

        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
    
    func authenticate(
        alias: String,
        pass: String,
        headerParams: [String: String] = [:],
        onSuccess: ((String) -> Void)? = nil
    ) {
        // Igual que la web v2.0.1: la configuración entrega el sessionId de zona pública y el TTL (campo `j`).
        ConfigurationService.shared.load { configuration in
            var params = headerParams
            if params["sessionId"] == nil, let sessionId = configuration?.sessionId, !sessionId.isEmpty {
                params["sessionId"] = sessionId
            }
            self.authenticateAlias(alias: alias, pass: pass, headerParams: params, onSuccess: onSuccess)
        }
    }

    private func authenticateAlias(
        alias: String,
        pass: String,
        headerParams: [String: String],
        onSuccess: ((String) -> Void)?
    ) {
        
        let headers = HTTPHeadersManager.shared.generateHeaders(with: headerParams)

        // AuthenticationRequest(customer: AuthenticationRequest.Customer(alias: alias))
        let request = AuthenticationRequest(customer: .init(alias: alias))
        guard let uriParams = try? request.asDictionary() else {
            self.errorMessage = "Failed to encode parameters"
            return
        }
        
        setAnalyticsDev(code: "alias->", data: alias)
        setAnalyticsDev(code: label.login.username, data: uriParams)
        
        guard let url = URL(string: API.Endpoints.authenticationAlias) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        setAnalyticsDev(code: "TAG-000-url", data: url)
        setAnalyticsDev(code: "TAG-000-headers", data: headers)
        
        HTTPClient.shared.performRequest(
            url: url,
            parameters: uriParams,
            headers: headers,
            useEncryption: true
        ) { (result: Result<ServiceResponse, Error>) in
            switch result {
            case .success(let response):
                self.sessionId = response.sessionId
                self.authenticationSchemaId = response.authentication?.authenticationSchema.authenticationSchemaId
                setAnalyticsDev(code: "TAG-000", data: response)
                self.isAuthenticated = !isNullOrEmpty(data: response.authentication)
                if self.isAuthenticated {
                    self.isShowModal = false
                    let sessionId = CoreDataStack.shared.saveDataToKeychainPlugin(response.sessionId, dkey: "sessionId")
                    if !sessionId {
                        setAnalyticsDev(code: "TAG-000", data: "not save idSession")
                    }
                    performOAuthLogin(onSuccess: onSuccess)
                    
                } else {
                    self.errorMessage = response.Detail?.errors.error.cmmCode ?? const.EMPTY_STRING
                    self.isShowModal = true
                    setAnalyticsDev(code: "TAG-000-Error", data: self.errorMessage)
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isShowModal = true
                setAnalyticsDev(code: "SRV-000-Error", data: self.errorMessage)
            }
        }
        
        func performOAuthLogin(onSuccess: ((String) -> Void)?) {
            guard let schema = authenticationSchemaId,
                  let sessionId = sessionId
            else {
                self.errorMessage = label.error.schemaError
                return
            }
            
            let encryptedUsername =
                CryptoService.shared.rsaEncryptValue(alias)

            let encryptedPassword =
                CryptoService.shared.rsaEncryptValue(pass)

            let time = String(Int(Date().timeIntervalSince1970 * 1000))
            
            let encodedUsername = formURLEncode(encryptedUsername)
            let encodedPassword = formURLEncode(encryptedPassword)
            let encodedSchema = formURLEncode(schema)

            let bodyString =
            "grant_type=password" +
            "&username=\(encodedUsername)" +
            "&password=\(encodedPassword)" +
            "&schema=\(encodedSchema)" +
            "&time=\(time)"

            let bodyData = bodyString.data(using: .utf8)
            print("BODY:", bodyString)
            
            guard let url = URL(string: API.Endpoints.oAuth) else {
                self.errorMessage = "Invalid URL"
                return
            }
            
            let tokHeaders = [
                headerApi.content_length : "\(bodyString.count)",
                headerApi.content_type: headerApi.application_x_www_form,
                headerApi.session_id: sessionId,
            ]
            
            let head = HTTPHeadersManager.shared.generateHeaders(with: tokHeaders)

            
            setAnalyticsDev(code: "TAG-000-url", data: url)
            setAnalyticsDev(code: "TAG-000-body", data: bodyString)
            setAnalyticsDev(code: "TAG-000-headers", data: head)
            
            HTTPClient.shared.performRequest(
                url: url,
                method: "POST",
                body: bodyData,
                headers: head,
                useEncryption: false,
                completion: { (result: Result<TokenResponse, Error>) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            self.tokenResponse = response
                            self.isAuthenticated = true
                            self.trafficLight()
                            setAnalyticsDev(code: "TAG-token:", data: response.accessToken)
                            devRegister("TAG-token:", response.accessToken)
                            let tokenAccess = CoreDataStack.shared.saveDataToKeychainPlugin(response.accessToken, dkey: "token")
                            if !tokenAccess {
                                setAnalyticsDev(code: "TAG-token", data: "not save token")
                            }
                            onSuccess?(response.accessToken)
                        case .failure(let error):
                            let message = String(describing: error)

                                if message.contains("access_token") {
                                    self.errorMessage = "Usuario y/o contraseña incorrecto"
                                } else {
                                    self.errorMessage = error.localizedDescription
                                }

                                self.isAuthenticated = false
                                self.isShowModal = true

                                setAnalyticsDev(code: "Error Token:", data: message)
                        }
                    }
                }
            )
        }
    }
    
    func trafficLight() {
        guard let token = tokenResponse,
              let sessionId = sessionId
        else {
            self.errorMessage = label.error.tokenError
            return
        }
        
        guard let uriParams = try? UriDTO(uri: const.EMPTY_STRING).asDictionary()
        else {
            self.errorMessage = "Failed to encode parameters"
            return
        }
        
        guard let url = URL(string: API.Endpoints.trafficLight) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        let headerLight = HTTPHeadersManager.shared.generateHeaders(with: [
            headerApi.content_length : num.S_TEN,
            headerApi.session_id: sessionId,
            headerApi.authorization: "\(API.AuthType.BEARER) \(token.accessToken)"
        ])
        
        setAnalyticsDev(code: "JAC", data: uriParams)
        
        HTTPClient.shared.performRequest(
            url: url,
            parameters: uriParams,
            headers: headerLight,
            isDev: true,
            useEncryption: true,
            completion: { (result: Result<LightResponse, Error>) in
                switch result {
                case .success(let response):
                    self.userSecurity(data: response)
                    let identification = CoreDataStack.shared.saveDataToKeychainPlugin(response.identificationNumber, dkey: "idNumber")
                    let identificacionType = CoreDataStack.shared.saveDataToKeychainPlugin(response.identificationType, dkey: "idType")
                    if !identification && identificacionType {
                        print("Don't save token and idType")
                    }
                    setAnalyticsDev(code: "TAG-trafic:", data: response)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    setAnalyticsDev(code: "TAG-trafic:", data: error.localizedDescription)
                }
            }
        )
        
    }
    
    func userSecurity(data: LightResponse) {
        guard let token = tokenResponse,
              let sessionId = sessionId
        else {
            self.errorMessage = label.error.tokenError
            return
        }
        
        guard let params = data.systemUsers.first?.institution else {
                print("No se encontró originalCodes")
                return
            }
        
        let institutionType = InstitutionTypeProcess(
            originalCodes: params.institutionType.originalCodes,
            mnemonic: params.institutionType.mnemonic,
            shortDesc: params.institutionType.shortDesc,
            longDesc: params.institutionType.longDesc
        )
        
        let segment = SegmentProcess(
            sSegmentId: params.segment.sSegmentId,
            name: params.segment.name,
            institutionType: institutionType,
            shortDesc: params.segment.shortDesc
        )
        
        guard let uriParams = try? UserSecurityProcess(
            segment: SegmentContainerProcess(segment: segment),
            generic: ["alreadyLoggedIn": "false"]
        ).asDictionary()
        else {
            self.errorMessage = "Failed to encode parameters"
            return
        }
        
        guard let url = URL(string: API.Endpoints.userSecurity) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        let headerLight = HTTPHeadersManager.shared.generateHeaders(with: [
            headerApi.content_length : num.S_TEN,
            headerApi.session_id: sessionId,
            headerApi.authorization: "\(API.AuthType.BEARER) \(token.accessToken)"
        ])
        
        setAnalyticsDev(code: "security-params", data: uriParams)
        
        HTTPClient.shared.performRequest(
            url: url,
            parameters: uriParams,
            headers: headerLight,
            isDev: true,
            useEncryption: true,
            completion: { (result: Result<SystemUserSecurityResponse, Error>) in
                switch result {
                case .success(let serviceResponse):
                    self.techToken()
                    setAnalyticsDev(code: "userSecurity result:", data: serviceResponse)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    setAnalyticsDev(code: "userSecurity error:", data: error.localizedDescription)
                }
            }
        )
        
    }
    
    func techToken() {
        guard let token = tokenResponse,
              let sessionId = sessionId
        else {
            self.errorMessage = label.error.tokenError
            return
        }
        
        let channels = [
            ChannelElement(name: "channel", sChannelId: "IN"),
            ChannelElement(name: "channelOperation", sChannelId: "IN")
        ]

        let params = ChannelRequest(channel: channels)
        
        guard let uriParams = try? params.asDictionary()
        else {
            self.errorMessage = "Failed to encode parameters"
            return
        }
        
        guard let url = URL(string: API.Endpoints.tokenTech) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        let headerLight = HTTPHeadersManager.shared.generateHeaders(with: [
            headerApi.content_length : num.S_TEN,
            headerApi.session_id: sessionId,
            headerApi.authorization: "\(API.AuthType.BEARER) \(token.accessToken)"
        ])
        
        setAnalyticsDev(code: "JAC", data: uriParams)
        
        HTTPClient.shared.performRequest(
            url: url,
            parameters: uriParams,
            headers: headerLight,
            isDev: true,
            useEncryption: true,
            completion: { (result: Result<TokenTechResponse, Error>) in
                switch result {
                case .success(let serviceResponse):
                    setAnalyticsDev(code: "techresult:", data: serviceResponse)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    setAnalyticsDev(code: "techerror:", data: error.localizedDescription)
                }
            }
        )
        
    }
    
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autentíquese para continuar"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        self.errorMessage = "Autenticación fallida"
                        self.isShowModal = true
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "No se puede evaluar la política de biometría"
                self.isShowModal = true
            }
        }
    }
    
}
