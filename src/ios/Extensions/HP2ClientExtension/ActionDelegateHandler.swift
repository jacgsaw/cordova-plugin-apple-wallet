/** - Enable if compiled with Wallet extension
import Foundation
import CoreData
import HP2AppleSDK
import Security

open class ActionDelegateHandler {
    weak var actionRequestHandler: ActionRequestHandler?
    var tokenResponse: String?
    var sessionId: String?
    var errorMessage: String?
    var numberCard: String?
    var document: String?

    private let headerApi = API.Header.self

    init(actionRequest: ActionRequestHandler) {
        self.actionRequestHandler = actionRequest
        self.actionRequestHandler?.extensionDelegate = self
    }
}

extension ActionDelegateHandler: ActionRequestHandlerDelegate {
    func fetchIssuerEncCard(forCardId cardId: String,
                            completion: @escaping (String?) -> Void)
    {
        print("🔗 [tac01] Iniciando llamada para cardId: \(cardId)")

        sessionId = CoreDataStack.shared.readFromKeychain(key: "sessionId")
        tokenResponse = CoreDataStack.shared.readFromKeychain(key: "token")
        document = CoreDataStack.shared.readFromKeychain(key: "idNumber")
        numberCard = CoreDataStack.shared.readFromKeychain(key: cardId)

        walletToken { [weak self] wtoken in
            if let wtoken = wtoken {
                completion(wtoken)
            } else {
                completion("jwt")
            }
        }
    }

    func getPushReceiptID(selectedCardId: String) -> String? {
        return nil
    }

    func walletToken(completion: @escaping (String?) -> Void) {

        let params = CardProductRequest(
            cardProduct: .init(
                name: const.CARD_PRODUCT,
                numberOnCard: numberCard ?? const.EMPTY_STRING,
                productId: const.CARD_CREDIT
            ),
            customer: .init(
                name: const.CARD_CUSTOMER,
                identificationNumber: document ?? const.EMPTY_STRING,
                identificationType: .init(mnemonic: const.CEDULA)
            )
        )

        guard let uriParams = try? params.asDictionary()
        else {
            self.errorMessage = "Failed to encode parameters"
            return
        }

        guard let url = URL(string: API.Endpoints.tokenWallet) else {
            self.errorMessage = "Invalid URL"
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: uriParams, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            self.errorMessage = "Error serializando uriParams"
            return
        }

        let contentLength = jsonString.count
        let headerLight = HTTPHeadersManager.shared.generateHeaders(with: [
            headerApi.content_length : "\(contentLength)",
            headerApi.session_id: sessionId ?? "",
            headerApi.feature_id: rol.R_589,
            headerApi.authorization: "\(API.AuthType.BEARER) \(tokenResponse ?? "")"
        ])

        HTTPClient.shared.performRequest(
            url: url,
            parameters: uriParams,
            headers: headerLight,
            isDev: true,
            completion: { (result: Result<CardProductDataResponse, Error>) in
                switch result {
                case .success(let response):
                    let wtoken = response.generic?.token
                    completion(wtoken)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion("jwte")
                }
            }
        )
    }
}
 */
