//
//  CryptoSession.swift
//  Davivienda
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 4/03/26.
//

//
//  CryptoSession.swift
//

import Foundation

final class CryptoSession {

    static let shared = CryptoSession()

    private init() {}

    /// Password usado para cifrar la petición
    /// Se reutiliza para descifrar la respuesta
    var password: String?

}
