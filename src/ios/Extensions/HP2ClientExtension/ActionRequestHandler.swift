import CoreData
import HP2AppleSDK
import MobileCoreServices
import PassKit
import UIKit
import UniformTypeIdentifiers

@objc protocol ActionRequestHandlerDelegate: AnyObject {
    @objc optional func getIssuerEncCard(selectedCardId: String) -> String?
    @objc optional func getPushReceiptID(selectedCardId: String) -> String?
}

class ActionRequestHandler: PKIssuerProvisioningExtensionHandler {
    private var institutionCode: String = ""
    private var groupID: String = ""
    public var hp2SDK: HP2? = nil

    override init() {
        super.init()
        do {
            self.groupID = try readInfoPlistValue(forKey: "groupID")
            self.institutionCode = try readInfoPlistValue(forKey: "institutionCode")
        } catch {
            print("The key [\(error.localizedDescription)] wasn't found in Info.plist.")
            print("Set the following properties in the build.json at the application level: 'institution-code' and 'group-id' and then reintegrate the plugin")
            // this is set nowadays to not crash the application but it should be edit into HP2ClientExtension`s info.plist
            // or set on build.json at app level the properties: 'institution-code' and 'group-id', then reintegrate plugin
            self.groupID = "group.com.davivienda.wallet.InAppProvisioningExtension"
            self.institutionCode = "com.davivienda-wallet.cr"
        }
        self.hp2SDK = HP2(institutionCode: self.institutionCode, groupID: self.groupID)
    }

    public weak var extensionDelegate: ActionRequestHandlerDelegate?
    private var actionDelegateHandler: ActionDelegateHandler?

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

    override func generateAddPaymentPassRequestForPassEntryWithIdentifier(_ identifier: String,
                                                                          configuration: PKAddPaymentPassRequestConfiguration,
                                                                          certificateChain certificates: [Data],
                                                                          nonce: Data,
                                                                          nonceSignature: Data,
                                                                          completionHandler completion: @escaping (PKAddPaymentPassRequest?) -> Void)
    {
        actionDelegateHandler = ActionDelegateHandler(actionRequest: self)
        let encCard = extensionDelegate?.getIssuerEncCard?(selectedCardId: identifier)
        let pushReceiptID = extensionDelegate?.getPushReceiptID?(selectedCardId: identifier)
        hp2SDK!.getAddPaymentPassRequest(certificateChain: certificates,
                                        nonceSignature: nonceSignature,
                                        nonce: nonce,
                                        pushReceiptID: pushReceiptID,
                                        issuerEncCard: encCard)
        { pkRequest in
            completion(pkRequest)
        }
    }

    func readInfoPlistValue(forKey key: String) throws -> String {
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
