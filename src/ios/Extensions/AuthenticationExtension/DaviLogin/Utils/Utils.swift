//
//  FunctionsUtils.swift
//  Davivienda
//
//  Created by Jose Cruz on 9/08/24.
//

import Foundation

func isNullOrEmpty<T>(data: T?) -> Bool {
    if let stringData = data as? String {
        return stringData.isEmpty
    } else {
        return data == nil
    }
}

