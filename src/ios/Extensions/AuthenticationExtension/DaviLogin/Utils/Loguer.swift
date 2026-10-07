//
//  Loguer.swift
//  Davivienda
//
//  Created by Alex Cruz on 28/08/24.
//

import Foundation

class Logger {
    static let shared = Logger()

    private init() {}

    private let fileManager = FileManager.default
    private var logFileURL: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent("app_log.txt")
    }

    func log(_ message: String) {
        guard let logFileURL = logFileURL else { return }

        let logMessage = "[\(Date())] \(message)\n"

        if fileManager.fileExists(atPath: logFileURL.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                if let data = logMessage.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            }
        } else {
            try? logMessage.write(to: logFileURL, atomically: true, encoding: .utf8)
        }
    }

    func readLog() -> String? {
        guard let logFileURL = logFileURL else { return nil }
        return try? String(contentsOf: logFileURL)
    }
}

