//
//  JwtDto.swift
//  HP2ClientExtension
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 10/06/25.
//

import Foundation

struct CardProductDataResponse: Codable {
    let sourceTime: String?
    let institutionId: String?
    let channelId: String?
    let serviceId: String?
    let serviceVersion: String?
    let serviceImplementationVersion: String?
    let traceNumber: String?
    let sessionId: String?
    let targetChannel: ChannelInfoToken?
    let executingChannel: ChannelInfoToken?
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
    let organizationType: OrganizationTypeToken?
    let internals: InternalsToken?
    let generic: WalletToken?
}

struct ChannelInfoToken: Codable {
    let mnemonic: String?
    let originalCodes: String?
    let shortDesc: String?
    let longDesc: String?
}

struct OrganizationTypeToken: Codable {
    let mnemonic: String?
    let originalCodes: String?
}

struct InternalsToken: Codable {
    let serviceRequestTimestamp: String?
    let serviceProviderName: String?
    let serviceProviderEntityName: String?
    let serviceResponseTimestamp: String?
    let serviceCoreResponseTime: String?
}

struct WalletToken: Codable {
    let token: String?
}
