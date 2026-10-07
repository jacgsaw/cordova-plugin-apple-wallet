//
//  GenerateIds.swift
//  Davivienda
//
//  Created by Jose Cruz on 8/08/24.
//

import Foundation

func generateIds(alias: String, documentType: String) -> (institutionId: String, userId: String) {
    let formattedAlias = alias.insertingLastSeparator(separator: "-")
    let institutionId = "uriTech=EMPRESA@59537;uriSFB=\(documentType)#\(formattedAlias);uriRules=\(documentType)#\(formattedAlias)"
    let userId = "uriTech=OPERADOR_EMPRESA@59552;uriSFB=\(documentType)#\(formattedAlias);uriRules=\(documentType)#\(formattedAlias)"
    return (institutionId, userId)
}

func getUserInstId(alias: String, documentType: String) -> [String: String] {
    let ids = generateIds(alias: alias, documentType: documentType)
    return [
        "institutionId": ids.institutionId,
        "userId": ids.userId
    ]
}
