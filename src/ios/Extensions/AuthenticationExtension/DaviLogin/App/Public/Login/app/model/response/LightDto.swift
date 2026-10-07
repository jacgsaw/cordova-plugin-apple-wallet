//
//  LightDto.swift
//  Davivienda
//
//  Created by Jose Cruz on 12/08/24.
//

import Foundation

struct LightResponseApi: Decodable {
    var success: Bool
    var message: String
}

struct LightResponse: Decodable {
    let firstName1: String
    let firstLogin: Bool
    let lastAccessDate: String
    let lastName1: String
    let identificationNumber: String
    let identificationType: String
    let systemUsers: [SystemUser]
    let IdentificationTypeLight: String?
    let emailAddressComplete: String
    let operatorName: String
    let systemUserSelected: SystemUser
    let semaforo: String
}

struct SystemUser: Decodable {
    let canLogin: String
    let institution: Institution
    let administrator: String
    let systemUserChannels: SystemUserChannels
    let firstLogin: String
    let systemUserType: SystemUserType
    let userId: String
    let roleTypes: String?
    let authentications: String?
}

struct Institution: Decodable {
    let country: Country
    let authenticationRequired: String
    let securitySchema: SecuritySchema
    let segment: Segment
    let limitOfCompany: String
    let limit: String
    let multLatin: String
    let institutionType: InstitutionType
    let mainOffice: String?
    let sIntitutionId: String
    let customer: CustomerLight
}

struct Country: Decodable {
    let originalCodes: String
    let mnemonic: String
    let shortDesc: String
}

struct SecuritySchema: Decodable {
    let originalCodes: String
    let mnemonic: String
}

struct Segment: Decodable {
    let sSegmentId: String
    let name: String
    let institutionType: InstitutionType
    let shortDesc: String
}

struct InstitutionType: Decodable {
    let originalCodes: String
    let mnemonic: String
    let shortDesc: String
    let longDesc: String
}

struct CustomerLight: Decodable {
    let transactionTypes: String?
    let name: String
    let identificationNumber: String
    let identificationType: IdentificationTypeLight?
}

struct IdentificationTypeLight: Decodable {
    let originalCodes: String
    let mnemonic: String
    let shortDesc: String
    let longDesc: String
}

struct SystemUserChannels: Decodable {
    let systemUserChannel: [SystemUserChannel]
}

struct SystemUserChannel: Decodable {
    let blocked: String
    let channel: Channel
}

struct Channel: Decodable {
    let originalCodes: String
    let mnemonic: String
    let shortDesc: String
    let sChannelId: String
    let longDesc: String?
}

struct SystemUserType: Decodable {
    let originalCodes: String
    let mnemonic: String
    let shortDesc: String
}

