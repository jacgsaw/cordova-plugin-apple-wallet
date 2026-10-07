//
//  TechDto.swift
//  Davivienda
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 5/06/25.
//

import Foundation

struct TokenTechResponse: Decodable {
    let sourceTime: String?
    let institutionId: String?
    let channelId: String?
    let serviceId: String?
    let traceNumber: String?
    let serviceVersion: String?
    let sessionId: String?
    let targetChannel: ChannelDetail?
    let executingChannel: ChannelDetail?
    let address: String?
    let sourceDate: String?
    let channelDispatchDate: String?
    let locale: String?
    let featureId: String?
    let institutionType: String?
    let msgTypeId: String?
    let terminalId: String?
    let organizationId: String?
    let organizationOperatorId: String?
    let executingOperatorId: String?
    let paginationInfo: String?
    let branchId: String?
    let userId: String?
    let parityCurrencyId: String?
    let localCurrencyId: String?
    let localCountryId: String?
    let bankId: String?
    let organizationType: OrganizationTech?
    let internals: InternalsBlock?
    let generic: GenericBlockTech?
    let token: TokenTech?
}

struct ChannelDetail: Decodable {
    let mnemonic: String?
    let originalCodes: String?
    let shortDesc: String?
    let longDesc: String?
}

struct OrganizationTech: Decodable {
    let mnemonic: String?
    let originalCodes: String?
}

struct InternalsBlock: Decodable {
    let serviceRequestTimestamp: String?
    let serviceProviderName: String?
    let serviceProviderEntityName: String?
    let serviceResponseTimestamp: String?
    let serviceCoreResponseTime: String?
}

struct GenericBlockTech: Decodable {
    let valid: String?
}

struct TokenTech: Decodable {
    let value: String?
}
