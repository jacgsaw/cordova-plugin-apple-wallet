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
