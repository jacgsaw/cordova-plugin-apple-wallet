//
//  JwtDtoRequest.swift
//  HP2ClientExtension
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 10/06/25.
//

import Foundation

struct CardProductRequest: Encodable {
    let cardProduct: CardProduct
    let customer: Customer

    struct CardProduct: Encodable {
        let name: String
        let numberOnCard: String
        let productId: String

        enum CodingKeys: String, CodingKey {
            case name = "@name"
            case numberOnCard
            case productId
        }
    }

    struct Customer: Encodable {
        let name: String
        let identificationNumber: String
        let identificationType: IdentificationType

        enum CodingKeys: String, CodingKey {
            case name = "@name"
            case identificationNumber
            case identificationType
        }

        struct IdentificationType: Encodable {
            let mnemonic: String
        }
    }
}
