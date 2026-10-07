//
//  ProcessUserDto.swift
//  Davivienda
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 4/06/25.
//

import Foundation

struct SystemUserSecurityResponse: Decodable {
    let sourceTime: String?
    let institutionId: String?
    let channelId: String?
    let traceNumber: String?
    let serviceId: String?
    let serviceVersion: String?
    let sessionId: String?
    let targetChannel: ChannelInfo?
    let executingChannel: ChannelInfo?
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
    let organizationType: ChannelInfo?
    let internals: InternalsInfo?
    let generic: GenericBlock?
    let systemUser: SystemUserBlock?
    let token: TokenBlock?
    let userSecurity: UserSecurityBlock?
}

struct ChannelInfo: Decodable {
    let mnemonic: String?
}

struct InternalsInfo: Decodable {
    let serviceRequestTimestamp: String?
    let serviceResponseTimestamp: String?
    let serviceCoreResponseTime: String?
}

struct GenericBlock: Decodable {
    let canLogin: String?
}

struct TokenBlock: Decodable {
    let value: String?
}

struct SystemUserBlock: Decodable {
    let userId: String?
    let administrator: String?
    let customer: CustomerBlock?
}

struct CustomerBlock: Decodable {
    let firstName1: String?
    let lastName1: String?
    let identificationNumber: String?
    let authentications: AuthenticationsBlock?
}

struct AuthenticationsBlock: Decodable {
    let authentication: [AuthenticationItem]?
}

struct AuthenticationItem: Decodable {
    let channel: ChannelBlock?
    let alias: String?
    let dynamicAuthenticacion: DynamicAuthenticacionBlock?
}

struct ChannelBlock: Decodable {
    let availableTransactions: String?
    let channelBank: String?
    let metaStatus: MetaStatusBlock?
    let status: StatusBlock?
    let sChannelId: String?
    let dateFrom: String?
    let singleSignOn: String?
    let mnemonic: String?
    let originalCodes: String?
    let shortDesc: String?
    let longDesc: String?
}

struct MetaStatusBlock: Decodable {
    let mnemonic: String?
    let originalCodes: String?
    let shortDesc: String?
}

struct StatusBlock: Decodable {
    let mnemonic: String?
    let originalCodes: String?
    let shortDesc: String?
    let longDesc: String?
}

struct DynamicAuthenticacionBlock: Decodable {
    let authenticationType: AuthenticationTypeBlock?
    let result: String?
    let channel: ChannelBlock?
    let keyStatusChannel: String?
    let login: String?
    let alias: String?
}

struct AuthenticationTypeBlock: Decodable {
    let authenticationTypeId: String?
    let weighting: String?
    let service: String?
    let metaStatus: MetaStatusBlock?
    let status: StatusBlock?
    let channels: ChannelsListBlock?
    let availableTransactions: String?
    let createDate: String?
    let authenticatesProfiling: String?
    let device: DeviceBlock?
    let mnemonic: String?
    let originalCodes: String?
    let shortDesc: String?
    let longDesc: String?
}

struct ChannelsListBlock: Decodable {
    let channel: [ChannelBlock]?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let channels = try? container.decode([ChannelBlock].self) {
            self.channel = channels
            return
        }

        if let single = try? container.decode(ChannelBlock.self) {
            self.channel = [single]
            return
        }

        self.channel = nil
    }
}


struct DeviceBlock: Decodable {
    let status: DeviceStatusBlock?
    let metaStatus: DeviceMetaStatusBlock?
    let sDeviceId: String?
    let createDate: String?
}

struct DeviceStatusBlock: Decodable {
    let mnemonic: String?
}

struct DeviceMetaStatusBlock: Decodable {
    let mnemonic: String?
}

struct UserSecurityBlock: Decodable {
    let itemSubproductPermissions: [ItemSubproductPermission]?
    let token: SecurityTokenBlock?
}

struct ItemSubproductPermission: Decodable {
    let query: Bool
    let credit: Bool
    let debit: Bool
    let subproduct: SubproductBlock?
    let securityItem: SecurityItemBlock?

    enum CodingKeys: String, CodingKey {
        case query, credit, debit, subproduct, securityItem
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        query = (try container.decodeIfPresent(String.self, forKey: .query)) == "true"
        credit = (try container.decodeIfPresent(String.self, forKey: .credit)) == "true"
        debit = (try container.decodeIfPresent(String.self, forKey: .debit)) == "true"
        subproduct = try container.decodeIfPresent(SubproductBlock.self, forKey: .subproduct)
        securityItem = try container.decodeIfPresent(SecurityItemBlock.self, forKey: .securityItem)
    }
}

struct SubproductBlock: Decodable {
    let subproductId: String?
}

struct SecurityItemBlock: Decodable {
    let securityItemId: String?
}

struct SecurityTokenBlock: Decodable {
    let value: String?
}

