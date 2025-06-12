import PassKit

struct PassKitHelper {
    static func makeAddPaymentPassRequest(
        configuration: PKAddPaymentPassRequestConfiguration,
        certificateChain: [Data],
        nonce: Data,
        nonceSignature: Data,
        issuerEncCard: String,
        completion: @escaping (PKAddPaymentPassRequest?) -> Void
    ) {
        guard let encryptedPassData = issuerEncCard.data(using: .utf8) else {
            completion(nil)
            return
        }
        let request = PKAddPaymentPassRequest()
        request.encryptedPassData = encryptedPassData
        print("encryptedPassData size: \(encryptedPassData.count)")

        completion(request)
    }
}
