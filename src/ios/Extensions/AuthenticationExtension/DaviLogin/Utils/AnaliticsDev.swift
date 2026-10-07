//
//  AnaliticsDev.swift
//  Davivienda
//
//  Created by Jose Cruz on 9/08/24.
//

import Foundation

func setAnalyticsDev<T>(code: String, data: T) {
    DispatchQueue.global(qos: .background).async {
        if API.logMode == "ANALITICS" {
            print("codex: \(code) - davidata: \(data)")
        }
    }
}

func devRegister<T>(_ code: String, _ data: T) {
    if API.logMode == "REGISTER" {
        print("🟢 [DAVIDATA] \(code) → \(data)")
    }
}
