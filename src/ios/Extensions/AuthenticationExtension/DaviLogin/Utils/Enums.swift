import Foundation

enum ButtonType: String {
    case primary
    case outline
    case crystal
}

enum ContainerType: String {
    case home
    case form
    case login
    case visual
    case result
}

enum HeaderType: String {
    case home
    case form
    case login
    case visual
    case result
}

struct ItemText {
    let num: String
    let text: String
}

enum LogColor: String {
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case reset = "\u{001B}[0;0m"
}

