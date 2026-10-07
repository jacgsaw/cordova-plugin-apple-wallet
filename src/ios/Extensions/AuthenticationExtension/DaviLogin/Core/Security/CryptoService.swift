//
//  CryptoService.swift
//

import Foundation
import CommonCrypto
import CryptoKit
import Security

struct CoESecurePayload: Codable {
    let m: String
    let s: String
    let i: String
}

struct CoEEncryptedPayload: Codable {
    let m: String
    let p: String
    let s: String
    let i: String
    /// RSA de `{"cryptographicIat": <ms>}`; solo se envía cuando el backend tiene TTL configurado.
    let j: String?
}

/// Debe coincidir con `@app/web/src/api/utilCrypto.ts` (cr-davivienda-app-mobile v2.0.1):
/// AES-256-GCM, key PBKDF2-SHA256 (1000 iteraciones), salt 16 bytes, IV 12 bytes, tag 128 bits.
class CryptoService {

    static let shared = CryptoService()

    /// Equivale a `configuration.ttl` de la web: agrega el campo `j` al request cifrado.
    var cryptographicTtlEnabled = false

    private let saltBytes = 16
    private let gcmIvBytes = 12
    private let gcmTagBytes = 16
    private let pbkdf2Iterations: UInt32 = 1000

    private var passwordStore: [String: String] = [:]
    private let passwordStoreLock = NSLock()

    // MARK: RANDOM BYTES

    private func randomBytes(_ length: Int) -> Data {
        var data = Data(count: length)
        data.withUnsafeMutableBytes {
            _ = SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        return data
    }

    // MARK: PBKDF2 SHA256

    private func deriveKey(password: String, salt: Data) -> SymmetricKey {

        let keyLength = 32
        let passwordData = Data(password.utf8)
        var derivedKey = Data(count: keyLength)

        derivedKey.withUnsafeMutableBytes { derivedKeyBytes in

            salt.withUnsafeBytes { saltBytes in

                passwordData.withUnsafeBytes { passwordBytes in

                    _ = CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.bindMemory(to: Int8.self).baseAddress,
                        passwordData.count,
                        saltBytes.bindMemory(to: UInt8.self).baseAddress,
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        pbkdf2Iterations,
                        derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress,
                        keyLength
                    )
                }
            }
        }

        return SymmetricKey(data: derivedKey)
    }

    // MARK: AES-GCM ENCRYPT

    /// Devuelve `ciphertext || tag`, igual que Web Crypto / Java `AES/GCM/NoPadding`.
    private func aesGcmEncrypt(data: Data, key: SymmetricKey, iv: Data) throws -> Data {

        let sealed = try AES.GCM.seal(data, using: key, nonce: AES.GCM.Nonce(data: iv))

        return sealed.ciphertext + sealed.tag
    }

    // MARK: AES-GCM DECRYPT

    private func aesGcmDecrypt(data: Data, key: SymmetricKey, iv: Data) throws -> Data {

        guard data.count >= gcmTagBytes else {
            throw NSError(domain: "Crypto", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid ciphertext"])
        }

        let box = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: iv),
            ciphertext: data.prefix(data.count - gcmTagBytes),
            tag: data.suffix(gcmTagBytes)
        )

        return try AES.GCM.open(box, using: key)
    }

// MARK: RSA ENCRYPT

    private func rsaEncrypt(password: String) -> String {

        let keyString = API.PUBLIC_KEY
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        let keyData = Data(base64Encoded: keyString)!

        let keyDict: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]

        let secKey = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, nil)!

        let data = password.data(using: .utf8)!

        let encrypted = SecKeyCreateEncryptedData(
            secKey,
            .rsaEncryptionPKCS1,
            data as CFData,
            nil
        )!

        return (encrypted as Data).base64EncodedString()
    }

    // MARK: ENCRYPT REQUEST

    func encrypt(body: [String: Any]) throws -> (String, CoEEncryptedPayload) {

        // Igual que `getRandomPassword()` de la web: 10 bytes aleatorios en hex.
        let password = randomBytes(10).hexString

        let requestId = UUID().uuidString

        let salt = randomBytes(saltBytes)
        let iv = randomBytes(gcmIvBytes)

        let key = deriveKey(password: password, salt: salt)

        let jsonData = try JSONSerialization.data(withJSONObject: body)

        let encrypted = try aesGcmEncrypt(data: jsonData, key: key, iv: iv)

        let m = encrypted.base64EncodedString()

        let p = rsaEncrypt(password: password)

        var j: String?
        if cryptographicTtlEnabled {
            let iat = Int64(Date().timeIntervalSince1970 * 1000)
            j = rsaEncrypt(password: "{\"cryptographicIat\":\(iat)}")
        }

        passwordStoreLock.lock()
        passwordStore[requestId] = password
        passwordStoreLock.unlock()

        return (
            requestId,
            CoEEncryptedPayload(
                m: m,
                p: p,
                s: salt.hexString,
                i: iv.hexString,
                j: j
            )
        )
    }

    // MARK: DECRYPT RESPONSE

    func decrypt(payload: SecureResponse, requestId: String) throws -> String {

        passwordStoreLock.lock()
        let password = passwordStore.removeValue(forKey: requestId)
        passwordStoreLock.unlock()

        guard let password = password else {
            throw NSError(domain: "Crypto", code: 500, userInfo: [NSLocalizedDescriptionKey: "Password not found"])
        }

        let salt = Data(hex: payload.s)
        let iv = Data(hex: payload.i)

        let key = deriveKey(password: password, salt: salt)

        guard let encrypted = Data(base64URLEncoded: payload.m) else {
            throw NSError(domain: "Crypto", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid base64"])
        }

        let decrypted = try aesGcmDecrypt(data: encrypted, key: key, iv: iv)

        return String(data: decrypted, encoding: .utf8) ?? ""
    }


    // MARK: PUBLIC RSA ENCRYPT

    func rsaEncryptValue(_ value: String) -> String {
        return rsaEncrypt(password: value)
    }
}

extension Data {

    /// Acepta Base64 estándar o Base64URL sin padding (Java `Base64.getUrlEncoder().withoutPadding()`).
    init?(base64URLEncoded string: String) {

        var normalized = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padLength = (4 - normalized.count % 4) % 4
        normalized += String(repeating: "=", count: padLength)

        self.init(base64Encoded: normalized)
    }

    init(hex: String) {

        self.init()

        var hex = hex
        var data = Data()

        while hex.count > 0 {

            let c = String(hex.prefix(2))
            hex = String(hex.dropFirst(2))

            var ch: UInt64 = 0
            Scanner(string: c).scanHexInt64(&ch)

            data.append(UInt8(ch))
        }

        self = data
    }

    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
