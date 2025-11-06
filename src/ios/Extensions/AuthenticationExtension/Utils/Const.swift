import Foundation

struct num {
    static let ONE = 1
    static let TWO = 2
    static let TEN = 10
    
    static let S_ONE = "1"
    static let S_TEN = "10"
}

struct const {
    static let EMPTY_STRING = ""
    static let SPACE = " "
    
    static let REGEX_LETTER_U = "[^A-Z]"
    static let REGEX_LETTER_L = "[^a-z]"
    static let REGEX_LETTER_N = "[^0-9]"
    static let REGEX_LETTER_U_L = "[^a-zA-Z]"
    static let REGEX_LETTER_U_L_N = "[^a-zA-Z0-9]"
    
    static let REGEX_USERNAME = "^[a-zA-Z0-9]*$"
    static let REGEX_PASSWORD = "^[a-zA-Z0-9.,]*$"
    
    static let CARD_PRODUCT = "cardProduct"
    static let CARD_CUSTOMER = "customer"
    static let CARD_CREDIT = "120"
    static let CARD_DEBIT = "160"
    static let CEDULA = "C"
    
    static let OK = "Ok"
}

struct pages {
    static let ON_BOARGING = "ON_BOARGING"
    static let ON_BOARGING_STEPS = "ON_BOARGING_STEPS"
    static let LOGIN = "LOGIN"
    static let LOGIN_TYC = "LOGIN_TYC"
    static let HOME = "HOME"
    
    static let VISUAL_ACCOUNTS = "VISUAL_ACCOUNTS"
    static let VISUAL_PAYMENTS = "VISUAL_PAYMENTS"
    static let VISUAL_TRANSFER = "VISUAL_TRANSFER"
    static let VISUAL_RECHARGE = "VISUAL_RECHARGE"
    static let VISUAL_SEE_MORE = "VISUAL_SEE_MORE"
}

struct documentType {
    static let DUI = "DUI"
}

struct rol {
    static let R_589 = "ROL@589"
}
