//
//  UserSecurityDto.swift
//  DaviLogin
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 4/06/25.
//

import Foundation

struct InstitutionTypeProcess: Codable {
    let originalCodes: String
    let mnemonic: String
    let shortDesc: String
    let longDesc: String
}

struct SegmentProcess: Codable {
    let sSegmentId: String
    let name: String
    let institutionType: InstitutionTypeProcess
    let shortDesc: String
}

struct SegmentContainerProcess: Codable {
    let segment: SegmentProcess
    enum CodingKeys: String, CodingKey {
        case segment = "segment"
    }
}

struct UserSecurityProcess: Codable {
    let segment: SegmentContainerProcess
    let generic: [String: String]
}
