//
//  NetworkModule.swift
//  Davivienda
//

import Foundation

class HTTPClient {

    static let shared = HTTPClient()

    private let decoder = JSONDecoder()

    // MARK: - MAIN REQUEST FUNCTION

    func performRequest<T: Decodable>(
        url: URL,
        method: String = "POST",
        parameters: [String: Any]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil,
        isDev: Bool = false,
        useEncryption: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method

        // =============================
        // HEADERS
        // =============================

        headers?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        var requestId: String?

        do {

            // =============================
            // REQUEST PARAMETERS
            // =============================

            if let parameters = parameters, body == nil {

                setAnalyticsDev(
                    code: "REQUEST PLAIN",
                    data: parameters
                )

                if useEncryption {

                    let encrypted = try CryptoService.shared.encrypt(body: parameters)

                    requestId = encrypted.0
                    let payload = encrypted.1

                    setAnalyticsDev(
                        code: "REQUEST ID",
                        data: requestId ?? ""
                    )

                    setAnalyticsDev(
                        code: "REQUEST ENCRYPTED",
                        data: payload
                    )

                    urlRequest.httpBody =
                        try JSONEncoder().encode(payload)

                } else {

                    urlRequest.httpBody =
                        try JSONSerialization.data(withJSONObject: parameters)
                }
            }

            // =============================
            // BODY DIRECTO (OAuth u otros)
            // =============================

            if let body = body {

                let bodyString =
                    String(data: body, encoding: .utf8) ?? ""

                setAnalyticsDev(
                    code: "REQUEST BODY RAW",
                    data: bodyString
                )

                urlRequest.httpBody = body
            }

        } catch {

            DispatchQueue.main.async {
                completion(.failure(error))
            }

            return
        }

        // =============================
        // REQUEST META
        // =============================

        setAnalyticsDev(
            code: "REQUEST URL",
            data: urlRequest.url?.absoluteString ?? ""
        )

        setAnalyticsDev(
            code: "REQUEST METHOD",
            data: urlRequest.httpMethod ?? ""
        )

        setAnalyticsDev(
            code: "REQUEST HEADERS",
            data: urlRequest.allHTTPHeaderFields ?? [:]
        )

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            if let error = error {

                setAnalyticsDev(
                    code: "HTTP ERROR",
                    data: error.localizedDescription
                )

                DispatchQueue.main.async {
                    completion(.failure(error))
                }

                return
            }

            guard let data = data else {

                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }

                return
            }

            do {

                // =============================
                // RESPONSE ENCRYPTED
                // =============================

                if useEncryption && self.isEncryptedResponse(data) {

                    let encryptedString =
                        String(data: data, encoding: .utf8) ?? ""

                    setAnalyticsDev(
                        code: "RESPONSE ENCRYPTED",
                        data: encryptedString
                    )

                    guard let requestId = requestId else {
                        throw NetworkError.cryptoError
                    }

                    let secure =
                        try self.decoder.decode(SecureResponse.self, from: data)

                    let decryptedString =
                        try CryptoService.shared.decrypt(
                            payload: secure,
                            requestId: requestId
                        )

                    setAnalyticsDev(
                        code: "RESPONSE DECRYPTED RAW",
                        data: decryptedString
                    )

                    guard
                        !decryptedString.isEmpty,
                        let decryptedData = decryptedString.data(using: .utf8)
                    else {

                        setAnalyticsDev(
                            code: "DECRYPT FAILED",
                            data: "Decrypted string empty"
                        )

                        throw NetworkError.decryptFailed
                    }

                    let value =
                        try self.decoder.decode(T.self, from: decryptedData)

                    DispatchQueue.main.async {
                        completion(.success(value))
                    }

                } else {

                    // =============================
                    // RESPONSE SIN ENCRIPTAR
                    // =============================

                    let raw =
                        String(data: data, encoding: .utf8) ?? ""

                    setAnalyticsDev(
                        code: "RESPONSE PLAIN",
                        data: raw
                    )

                    let value =
                        try self.decoder.decode(T.self, from: data)

                    DispatchQueue.main.async {
                        completion(.success(value))
                    }
                }

            } catch {

                setAnalyticsDev(
                    code: "HTTP-DECODE-ERROR",
                    data: error.localizedDescription
                )

                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }

    // MARK: - DETECTAR RESPONSE ENCRYPTED

    private func isEncryptedResponse(_ data: Data) -> Bool {

        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let json = object as? [String: Any]
        else { return false }

        return
            json["m"] != nil &&
            json["s"] != nil &&
            json["i"] != nil
    }
}
