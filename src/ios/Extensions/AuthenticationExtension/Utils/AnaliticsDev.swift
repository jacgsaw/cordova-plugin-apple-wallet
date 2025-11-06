//
//  LogDebug.swift
//  Davivienda
//
//  Created by Jose Cruz on 9/08/24.
//

import Foundation


func setAnalyticsDev<T>(code: String, data: T) -> Void {
    if API.environment == "DEV" {
        print("code: \(code) - davidata: \(data)")
    }
}

