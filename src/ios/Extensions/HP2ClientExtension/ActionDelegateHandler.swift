import Foundation

class ActionDelegateHandler {
    
    let actionRequestHandler: ActionRequestHandler?
    
    init(actionRequest: ActionRequestHandler) {
        self.actionRequestHandler = actionRequest
        self.actionRequestHandler?.extensionDelegate = self
    }
}

extension ActionDelegateHandler: ActionRequestHandlerDelegate {
    func getIssuerEncCard(selectedCardId: String) -> String? {
        return "321321"
    }

    func getPushReceiptID(selectedCardId: String) -> String? {
        return nil
    }
}
