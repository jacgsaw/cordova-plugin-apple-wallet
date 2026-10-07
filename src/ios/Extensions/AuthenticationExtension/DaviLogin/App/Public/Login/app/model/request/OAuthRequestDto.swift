//
//  OAuthRequestDto.swift
//  Davivienda
//
//  Created by Jose Cruz on 9/08/24.
//

import Foundation

struct OAuthParameters {
    let grantType: String = "password"
    let username: String
    let password: String
    let schema: String
    let time: String = getCurrentTimeFormatted()
    
    func toDictionary() -> [String: String] {
        return [
            "grant_type": grantType,
            "username": username,
            "password": password,
            "schema": schema,
            "time": time
        ]
    }
}



