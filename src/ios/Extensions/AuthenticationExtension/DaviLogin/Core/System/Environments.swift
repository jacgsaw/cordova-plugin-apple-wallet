//
//  Environments.swift
//  Davivienda
//
//  Created by Jose Cruz on 7/08/24.
//

import Foundation


struct API {
    
    static var environment: String {
        if let env = Bundle.main.object(forInfoDictionaryKey: "DAVI_ENV") as? String {
            return env
        }
        if let saved = UserDefaults.standard.string(forKey: "savedEnvironment") {
            return saved
        }
        return "PROD"
    }
    
    /// Modo de logs (DAVI_CTR en Info.plist): ANALITICS o REGISTER. Independiente del ambiente.
    static var logMode: String {
        return (Bundle.main.object(forInfoDictionaryKey: "DAVI_CTR") as? String ?? "").uppercased()
    }
    
    static func setEnvironment(_ env: String) {
        UserDefaults.standard.set(env, forKey: "savedEnvironment")
    }
    
    static var URL: String {
        switch environment {
        case "DEV":
            return "https://davi-dev-cr-cluster.technisys.net"
        case "INT":
            return "https://davi-int-cr.technisys.net"
        case "UAT":
            return "https://davi-uat-cr-cluster.technisys.net"
        case "PROD":
            return "https://appmobile.davivienda.cr"
        default:
            return "https://appmobile.davivienda.cr"
        }
    }
    
    static let restBasePath = "/bankingserver-davi/rest/callService/json"
    
    struct Endpoints {
        static let configuration = "\(API.URL)\(API.restBasePath)/public/massiveSelectConfigurationBS"
        static let authenticationAlias = "\(API.URL)\(API.restBasePath)/public/singleSelectDynamicAuthenticationByAlias"
        static let trafficLight = "\(API.URL)\(API.restBasePath)/processAutoSelectionOperatorBS"
        static let userSecurity = "\(API.URL)\(API.restBasePath)/processSystemUserSecurity"
        static let tokenTech = "\(API.URL)\(API.restBasePath)/processTokenTechCreation"
        static let tokenWallet = "\(API.URL)\(API.restBasePath)/singleSelectCardProductDataSFB"
        static let oAuth = "\(API.URL)/bankingserver-davi/oauth/token"
    }
    
    struct AuthType {
        static let BEARER = "Bearer"
        static let BASIC = "Basic"
        static let GENERIC = "YmFua2luZy1hcGktY2xpZW50OmJhbmtpbmctYXBpLXNlY3JldA=="
    }
    
    struct Header {
        static let content_length = "Content-Length"
        static let content_type = "Content-Type"
        static let session_id = "sessionId"
        static let authorization = "Authorization"
        static let feature_id = "featureId"
        
        static let application_x_www_form = "application/x-www-form-urlencoded;charset=UTF-8"
    }
    
    static var PUBLIC_KEY: String {
        switch environment {
        case "DEV":
            return """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzWvO2u06g+LR35hzI2BK9PA35AGz+UBq5w4/N/yjSQcqlWUW80RX/d4jPHOItVWcBOYIjizE8lJCMCjNubiYE3pHwEsSxJ9V9XAnjZeCgspnalIKMpa2mxxfKxpkrmnNsJ2erQvVT2KCWAZnrWL/jh5cKlY18y/YHA1eXCLB8WbLZi1aK112MMWjHm82nuGDSQ5jW2cM6Z/Fpl+k2FUQmIqZq4DArcHJEIPun52HA0PRsPT62uDwvTm3mDFo9U/uuNvTq0CKsCE3uOZrDH6KhI0KR4NiDR3WmRB1YXdI+uNvPw2CVGWkZg6tUBjGqHADcdjb7wmRzTTgRwjL21IJIwIDAQAB
-----END PUBLIC KEY-----
"""
        case "INT":
            return """
-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzWvO2u06g+LR35hzI2BK9PA35AGz+UBq5w4/N/yjSQcqlWUW80RX/d4jPHOItVWcBOYIjizE8lJCMCjNubiYE3pHwEsSxJ9V9XAnjZeCgspnalIKMpa2mxxfKxpkrmnNsJ2erQvVT2KCWAZnrWL/jh5cKlY18y/YHA1eXCLB8WbLZi1aK112MMWjHm82nuGDSQ5jW2cM6Z/Fpl+k2FUQmIqZq4DArcHJEIPun52HA0PRsPT62uDwvTm3mDFo9U/uuNvTq0CKsCE3uOZrDH6KhI0KR4NiDR3WmRB1YXdI+uNvPw2CVGWkZg6tUBjGqHADcdjb7wmRzTTgRwjL21IJIwIDAQAB-----END PUBLIC KEY-----
"""
        case "UAT":
            return """
-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzWvO2u06g+LR35hzI2BK9PA35AGz+UBq5w4/N/yjSQcqlWUW80RX/d4jPHOItVWcBOYIjizE8lJCMCjNubiYE3pHwEsSxJ9V9XAnjZeCgspnalIKMpa2mxxfKxpkrmnNsJ2erQvVT2KCWAZnrWL/jh5cKlY18y/YHA1eXCLB8WbLZi1aK112MMWjHm82nuGDSQ5jW2cM6Z/Fpl+k2FUQmIqZq4DArcHJEIPun52HA0PRsPT62uDwvTm3mDFo9U/uuNvTq0CKsCE3uOZrDH6KhI0KR4NiDR3WmRB1YXdI+uNvPw2CVGWkZg6tUBjGqHADcdjb7wmRzTTgRwjL21IJIwIDAQAB-----END PUBLIC KEY-----
"""
        case "PROD":
            return """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzWvO2u06g+LR35hzI2BK9PA35AGz+UBq5w4/N/yjSQcqlWUW80RX/d4jPHOItVWcBOYIjizE8lJCMCjNubiYE3pHwEsSxJ9V9XAnjZeCgspnalIKMpa2mxxfKxpkrmnNsJ2erQvVT2KCWAZnrWL/jh5cKlY18y/YHA1eXCLB8WbLZi1aK112MMWjHm82nuGDSQ5jW2cM6Z/Fpl+k2FUQmIqZq4DArcHJEIPun52HA0PRsPT62uDwvTm3mDFo9U/uuNvTq0CKsCE3uOZrDH6KhI0KR4NiDR3WmRB1YXdI+uNvPw2CVGWkZg6tUBjGqHADcdjb7wmRzTTgRwjL21IJIwIDAQAB
-----END PUBLIC KEY-----
"""
        default:
            return """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzWvO2u06g+LR35hzI2BK9PA35AGz+UBq5w4/N/yjSQcqlWUW80RX/d4jPHOItVWcBOYIjizE8lJCMCjNubiYE3pHwEsSxJ9V9XAnjZeCgspnalIKMpa2mxxfKxpkrmnNsJ2erQvVT2KCWAZnrWL/jh5cKlY18y/YHA1eXCLB8WbLZi1aK112MMWjHm82nuGDSQ5jW2cM6Z/Fpl+k2FUQmIqZq4DArcHJEIPun52HA0PRsPT62uDwvTm3mDFo9U/uuNvTq0CKsCE3uOZrDH6KhI0KR4NiDR3WmRB1YXdI+uNvPw2CVGWkZg6tUBjGqHADcdjb7wmRzTTgRwjL21IJIwIDAQAB
-----END PUBLIC KEY-----
"""
        }
    }
    
}
