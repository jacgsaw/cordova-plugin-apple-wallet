//
//  StringExtensions.swift
//  Davivienda
//
//  Created by Jose Cruz on 8/08/24.
//

import Foundation

extension String {
    func insertingLastSeparator(separator: String) -> String {
        guard self.count > 1 else { return self }
        let lastCharacter = self.suffix(1)
        let restOfString = self.dropLast()
        return "\(restOfString)\(separator)\(lastCharacter)"
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
