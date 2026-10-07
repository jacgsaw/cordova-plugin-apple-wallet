//
//  AuthenticationDto.swift
//  Davivienda
//
//  Created by Jose Cruz on 6/08/24.
//

import Foundation

struct AuthenticationResponse: Decodable {
    var success: Bool
    var message: String
}

struct ServiceResponse: Decodable {
    let sourceTime: String
    let institutionId: String
    let userId: String
    let channelId: String
    let institutionType: String?
    let serviceId: String
    let serviceVersion: String
    let featureId: String?
    let sessionId: String
    let organizationType: OrganizationType
    let executingChannel: ExecutingChannel
    let executingOperatorId: String
    let channelDispatchDate: String
    let organizationId: String
    let organizationOperatorId: String
    let traceNumber: String
    let address: String
    let terminalId: String
    let locale: String
    let branchId: String
    let authentication: Authentication?
    let customer: Customer?
    let Detail: Errors?
}

struct OrganizationType: Decodable {
    let mnemonic: String
    let originalCodes: String
    let shortDesc: String?
    let longDesc: String?
}

struct ExecutingChannel: Decodable {
    let mnemonic: String
    let originalCodes: String
    let shortDesc: String?
    let longDesc: String?
}

struct Authentication: Decodable {
    let dynamicAuthenticacion: DynamicAuthentication
    let authenticationSchema: AuthenticationSchema
    let authenticationId: String
}

struct DynamicAuthentication: Decodable {
    let alias: String
    let authenticationType: AuthenticationType?
    let result: String
    let login: String
}

struct AuthenticationType: Decodable {
    let authenticationTypeId: String
    let weighting: String
    let authenticatesProfiling: String
    let device: Device
}

struct Device: Decodable {
    let status: DeviceStatus?
    let metaStatus: DeviceStatus?
    let sDeviceId: String?
    let createDate: String?
}

struct DeviceStatus: Decodable {
    let mnemonic: String?
}

struct AuthenticationSchema: Decodable {
    let authenticationSchemaId: String
}

struct Customer: Decodable {
    let avatar: Avatar
    let residenceCode: ResidenceCode
    let identificationType: IdentificationType
    let identificationNumber: String
    let firstName1: String
    let lastName1: String
}

struct Avatar: Decodable {
    let avatarNumber: String
}

struct ResidenceCode: Decodable {
    let mnemonic: String
    let originalCodes: String
    let shortDesc: String?
}

struct IdentificationType: Decodable {
    let mnemonic: String
    let originalCodes: String
    let shortDesc: String
    let longDesc: String
}

struct Errors: Decodable {
    let errors: ErrorObject
}

struct ErrorObject: Decodable {
    let error: ErrorLogin
}

struct ErrorLogin: Decodable {
    let severity: String
    let sourceCode: String
    let detail: String
    let cmmCode: String
}
