//
//  AuthenticationRequestDto.swift
//  Davivienda
//
//  Created by Jose Cruz on 9/08/24.
//

import Foundation

struct AuthenticationRequest: Encodable {
    let customer: Customer
    
    struct Customer: Encodable {
        let alias: String
    }
}


