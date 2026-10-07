//
//  CryptoModels.swift
//  Davivienda
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 4/03/26.
//

import Foundation

// MARK: - Secure Request Payload
// Estructura enviada al backend (Tech / BankingServer)

struct SecurePayload: Codable {

    /// Mensaje cifrado (AES-256-GCM, ciphertext + tag en Base64)
    let m: String

    /// Password cifrado con RSA (Base64)
    let p: String

    /// Salt usado en PBKDF2 (HEX)
    let s: String

    /// IV usado en AES (HEX)
    let i: String

}


// MARK: - Secure Response Payload
// Estructura que devuelve el backend

struct SecureResponse: Codable {

    /// Mensaje cifrado (AES-256-GCM, ciphertext + tag en Base64)
    let m: String

    /// Salt usado para generar la key (HEX)
    let s: String

    /// IV usado para AES (HEX)
    let i: String

}


// MARK: - Wrapper para enviar payload cifrado
// Útil si necesitas envolver el payload dentro de otro objeto

struct EncryptedRequest: Codable {

    let payload: SecurePayload

}


// MARK: - Wrapper para recibir payload cifrado

struct EncryptedResponse: Codable {

    let payload: SecureResponse

}


// MARK: - Debug Model
// Útil para logs en desarrollo

struct CryptoDebugLog: Codable {

    let originalRequest: String
    let encryptedRequest: SecurePayload
    let password: String
    let requestId: String

}
