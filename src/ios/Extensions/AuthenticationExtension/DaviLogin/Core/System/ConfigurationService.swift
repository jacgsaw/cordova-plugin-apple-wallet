//
//  ConfigurationService.swift
//  Davivienda
//

import Foundation

/// Respuesta de `massiveSelectConfigurationBS`; solo se leen los campos que necesita el login.
struct ConfigurationResponse: Decodable {

    /// Session id de zona pública (DSAPP-5159); se envía en el header `sessionId` de los servicios públicos.
    let sessionId: String?

    /// Equivale a `if (ttl)` de la web: con TTL, cada request cifrado lleva el campo `j`.
    let ttlEnabled: Bool

    private enum CodingKeys: String, CodingKey {
        case sessionId
        case ttl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        sessionId = try? container.decode(String.self, forKey: .sessionId)

        if let value = try? container.decode(Bool.self, forKey: .ttl) {
            ttlEnabled = value
        } else if let value = try? container.decode(Double.self, forKey: .ttl) {
            ttlEnabled = value > 0
        } else if let value = try? container.decode(String.self, forKey: .ttl) {
            let trimmed = value.trimmingCharacters(in: .whitespaces).lowercased()
            ttlEnabled = !trimmed.isEmpty && trimmed != "0" && trimmed != "false"
        } else {
            ttlEnabled = false
        }
    }
}

/// Replica `getConfiguration()` de cr-davivienda-app-mobile v2.0.1: se consulta antes de los servicios públicos.
final class ConfigurationService {

    static let shared = ConfigurationService()

    private init() {}

    func load(completion: @escaping (ConfigurationResponse?) -> Void) {

        guard let url = URL(string: API.Endpoints.configuration) else {
            completion(nil)
            return
        }

        let headers = HTTPHeadersManager.shared.generateHeaders(with: [:])

        HTTPClient.shared.performRequest(
            url: url,
            parameters: [:],
            headers: headers,
            useEncryption: false
        ) { (result: Result<ConfigurationResponse, Error>) in
            switch result {
            case .success(let configuration):
                CryptoService.shared.cryptographicTtlEnabled = configuration.ttlEnabled
                setAnalyticsDev(code: "CONFIGURATION", data: "ttl: \(configuration.ttlEnabled), sessionId: \(!isNullOrEmpty(data: configuration.sessionId))")
                completion(configuration)
            case .failure(let error):
                setAnalyticsDev(code: "CONFIGURATION-ERROR", data: error.localizedDescription)
                completion(nil)
            }
        }
    }
}
