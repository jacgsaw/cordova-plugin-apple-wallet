//
//  TokenDto.swift
//  Davivienda
//
//  Created by Jose Cruz on 9/08/24.
//

import Foundation

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let expiresIn: Int
    let scope: String
    let tokenStore: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope
        case tokenStore = "tokenStore"
    }
}
