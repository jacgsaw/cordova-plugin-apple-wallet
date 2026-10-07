//
//  HTTPHeadersManager.swift
//  Davivienda
//
//  Created by Jose Cruz on 8/08/24.
//

import Foundation

struct HTTPHeadersManager {
    static let shared = HTTPHeadersManager()

    private init() {}
    
    func generateHeaders(with params: [String: String], addHeaders: [String: String]? = nil) -> [String: String] {
        var headers: [String: String] = [
            "Accept": "application/json;charset=UTF-8",
            "Accept-Encoding": "gzip, deflate, br, zstd",
            "Accept-Language": "es-ES,es;q=0.9",
            "Authorization": params["Authorization"] ?? "\(API.AuthType.BASIC) \(API.AuthType.GENERIC)",
            "Content-Type": params["Content-Type"] ?? "application/json;charset=UTF-8",
            "Cache-Control": "no-cache",
            "locale": params["locale"] ?? "es_CR",
            "paginationInfo": params["paginationInfo"] ?? const.EMPTY_STRING,
            "sessionId": params["sessionId"] ?? const.EMPTY_STRING,
            "Connection": "keep-alive",
            "Sec-Fetch-Dest": "empty",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Site": "cross-site",
            "Host": URL(string: API.URL)?.host ?? API.URL,
            "featureId": params["featureId"] ?? "ROL@401",
        ]
        
        for (key, value) in params {
                headers[key] = value
            }
        
        if let additional = addHeaders {
            for (key, value) in additional {
                headers[key] = value
            }
        }
        
        return headers
    }
}
