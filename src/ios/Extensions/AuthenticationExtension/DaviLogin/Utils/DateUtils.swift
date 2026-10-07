//
//  DateUtils.swift
//  Davivienda
//
//  Created by Jose Cruz on 9/08/24.
//

import Foundation

func getCurrentTimeFormatted() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
    let currentDate = Date()
    let formattedDate = dateFormatter.string(from: currentDate)
    return formattedDate
}
