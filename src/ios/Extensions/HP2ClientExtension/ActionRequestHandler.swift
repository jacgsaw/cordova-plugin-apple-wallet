/** - Enable if compiled with Wallet extension
import CoreData
import HP2AppleSDK
import MobileCoreServices
import PassKit
import UIKit
import UniformTypeIdentifiers
import CryptoKit

protocol ActionRequestHandlerDelegate: AnyObject {
    func fetchIssuerEncCard(
        forCardId cardId: String,
        completion: @escaping (String?) -> Void
    )
    func getPushReceiptID(selectedCardId: String) -> String?
}

class ActionRequestHandler: PKIssuerProvisioningExtensionHandler {
    private var institutionCode: String = ""
    private var groupID: String = ""
    public var hp2SDK: HP2? = nil

    public weak var extensionDelegate: ActionRequestHandlerDelegate?
    private var actionDelegateHandler: ActionDelegateHandler?

    override init() {
        super.init()
        do {
            self.groupID         = try readInfoPlistValue(forKey: "groupID")
            self.institutionCode = try readInfoPlistValue(forKey: "institutionCode")
        } catch {
            print("[Tag01] The key [\(error.localizedDescription)] wasn't found in Info.plist.")
            self.groupID         = "group.com.davivienda.wallet.InAppProvisioningExtension"
            self.institutionCode = "DVCR-430"
        }
        self.hp2SDK = HP2(institutionCode: self.institutionCode,
                          groupID: self.groupID)
    }

    func printCardFromCoreDataById(cardID: String) {
            guard let hp2 = self.hp2SDK else {
                return
            }
        }

    override func status(completion: @escaping (PKIssuerProvisioningExtensionStatus) -> Void) {
        let extensionStatus = hp2SDK!.getProvisioningExtensionStatus()
        completion(extensionStatus)
    }

    override func passEntries(completion: @escaping ([PKIssuerProvisioningExtensionPassEntry]) -> Void) {
        let passEntriesAvailable = hp2SDK!.getPassEntriesAvailable()
        completion(passEntriesAvailable)
    }

    override func remotePassEntries(completion: @escaping ([PKIssuerProvisioningExtensionPassEntry]) -> Void) {
        let remotePassEntriesAvailable = hp2SDK!.getPassEntriesAvailable()
        completion(remotePassEntriesAvailable)
    }

    override func generateAddPaymentPassRequestForPassEntryWithIdentifier(
        _ identifier: String,
        configuration: PKAddPaymentPassRequestConfiguration,
        certificateChain certificates: [Data],
        nonce: Data,
        nonceSignature: Data,
        completionHandler completion: @escaping (PKAddPaymentPassRequest?) -> Void
    ) {
        let certB64List = certificates.map { $0.base64EncodedString() }

        if let firstCert = certificates.first {
            print("[Tag] First certificated (Base64):", firstCert.base64EncodedString())
        } else {
            print("[Tag] is not chain")
        }

        printCardFromCoreDataById(cardID: identifier)

        let nonceB64     = nonce.base64EncodedString()
        let signatureB64 = nonceSignature.base64EncodedString()

        actionDelegateHandler = ActionDelegateHandler(actionRequest: self)

        extensionDelegate?.fetchIssuerEncCard(forCardId: identifier) { encCard in
            print("[Tag] encryptedCard received:", encCard ?? "nil")

            guard let encCard = encCard else {
                print("[Tag] no se obtuvo encryptedCard, cancelando")
                return completion(nil)
            }

            let pushReceiptID = self.extensionDelegate?.getPushReceiptID(selectedCardId: identifier)

            self.hp2SDK!.getAddPaymentPassRequest(
                certificateChain: certificates,
                nonceSignature: nonceSignature,
                nonce: nonce,
                pushReceiptID: nil,
                issuerEncCard: encCard
            ) { pkRequest in
                print("[Tag] callback de HP2SDK con PKAddPaymentPassRequest:", pkRequest as Any)
                completion(pkRequest)
            }
        }
    }

    private func readInfoPlistValue(forKey key: String) throws -> String {
        let bundle = Bundle.main
        if let value = bundle.object(forInfoDictionaryKey: key) as? String {
            return value
        }
        throw InfoPlistError.keyNotFound(key)
    }
}

enum InfoPlistError: Error {
    case keyNotFound(String)
}
 */
