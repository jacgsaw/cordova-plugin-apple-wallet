//
//  TechTokenDto.swift
//  Davivienda
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 5/06/25.
//

import Foundation

struct ChannelRequest: Encodable {
    let channel: [ChannelElement]
}

struct ChannelElement: Encodable {
    let name: String
    let sChannelId: String

    enum CodingKeys: String, CodingKey {
        case name = "@name"
        case sChannelId
    }
}
