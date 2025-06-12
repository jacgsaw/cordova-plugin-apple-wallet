import Foundation
import HP2AppleSDK
import UIKit
import PassKit
import Security

@objc(HP2CordovaPlugin)
class HP2CordovaPlugin : CDVPlugin {
    private var institutionCode: String?
    private var groupID: String?
    private var mHP2: HP2?
    private var provisioningEvents = ProvisioningEvents()

@objc(init:)
func `init`(command: CDVInvokedUrlCommand) {
    let inst = command.arguments[0] as? String ?? ""
    let grp  = command.arguments[1] as? String ?? ""

    var status: CDVCommandStatus = .error
    var result = toJson(
        method: "init",
        data: [:],
        detail: "",
        error: true,
        message: "Invalid parameter."
    )

    if !inst.isEmpty && !grp.isEmpty {
        institutionCode = inst
        groupID = grp
        mHP2 = HP2(institutionCode: inst, groupID: grp)
        provisioningEvents = ProvisioningEvents()

        status = .ok
        result = toJson(
            method: "init",
            data: [
                "institutionCode": inst,
                "groupID": grp
            ],
            detail: "Init...",
            error: false,
            message: "Status: \(status == .ok ? "OK" : "ERROR")"
        )
    }

    let pluginResult = CDVPluginResult(status: status, messageAs: result)
    commandDelegate.send(pluginResult, callbackId: command.callbackId)
}

@objc(updateDataBase:)
func updateDataBase(command: CDVInvokedUrlCommand) {
    // Comprobamos que ya estemos inicializados
    guard
        let inst = institutionCode,
        let grp  = groupID
    else {
        let res = toJson(
            method: "updateDataBase",
            data: [:],
            detail: "",
            error: true,
            message: "Plugin not initialized"
        )
        let pr = CDVPluginResult(status: .error, messageAs: res)
        return commandDelegate.send(pr, callbackId: command.callbackId)
    }

    // Obtenemos y parseamos el JSON de tarjetas
    let cardDataList = command.arguments[1] as? String ?? ""
    let cards = toCardDataModel(jsonString: cardDataList)

    // Aseguramos la instancia de HP2
    mHP2 = mHP2 ?? HP2(institutionCode: inst, groupID: grp)

    // Logs para consola
    print("💾 [HP2CordovaPlugin] Calling updateDataBase with \(cards.count) items")
    mHP2?.updateDataBase(cardDataList: cards)
    print("✅ [HP2CordovaPlugin] updateDataBase completed — saved \(cards.count) records")

    // Preparamos la respuesta con los IDs guardados
    let savedInfo = cards.map {
        ["cardId": $0.cardID, "lastFour": $0.lastFourDigits]
    }
    let res = toJson(
        method: "updateDataBase",
        data: ["savedCards": savedInfo],
        detail: "Saved \(cards.count) records",
        error: false,
        message: ""
    )
    let pr = CDVPluginResult(status: .ok, messageAs: res)
    commandDelegate.send(pr, callbackId: command.callbackId)
}


    @objc(isAvailable:)
    func isAvailable(command: CDVInvokedUrlCommand) {
        var result = toJson(method: "isAvailable", data: [:], detail: "", error: true, message: "Invalid parameter.")

        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: result
        )

        let instCode = command.arguments[0] as? String ?? ""

        if !instCode.isEmpty {
            mHP2 = (mHP2 == nil) ? HP2(institutionCode: instCode) : mHP2
            let isAvailable = mHP2?.isAvailable() ?? false

            result = toJson(method: "isAvailable", data: ["isAvailable":isAvailable], detail: "", error: false, message: "")

            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: result
            )
        }

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    @objc(getVersion:)
    func getVersion(command: CDVInvokedUrlCommand) {
        var result = toJson(method: "getVersion", data: [:], detail: "", error: true, message: "Invalid parameter.")

        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: result
        )

        let instCode = command.arguments[0] as? String ?? ""

        if !instCode.isEmpty {
            mHP2 = (mHP2 == nil) ? HP2(institutionCode: instCode) : mHP2
            let versioName = mHP2?.getVersion()

            result = toJson(method: "getVersion", data: ["versioName":versioName as Any], detail: "", error: false, message: "")

            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: result
            )
        }

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    @objc(isAvailableForCard:)
    func isAvailableForCard(command: CDVInvokedUrlCommand) {
        var result = toJson(method: "isAvailableForCard", data: [:], detail: "", error: true, message: "Invalid parameter.")

        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: result
        )

        let instCode = command.arguments[0] as? String ?? ""
        let panId = command.arguments[1] as? String ?? ""

        if !instCode.isEmpty && !panId.isEmpty {
            mHP2 = (mHP2 == nil) ? HP2(institutionCode: instCode) : mHP2
            let isAvailableForCard = mHP2?.isAvailableForCard(panRefId: panId) ?? false

            result = toJson(method: "isAvailableForCard", data: ["isAvailableForCard":isAvailableForCard], detail: "", error: false, message: "")

            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: result
            )
        }

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    @objc(getCards:)
    func getCards(command: CDVInvokedUrlCommand) {
        var result = toJson(method: "getCards", data: [:], detail: "", error: true, message: "Invalid parameter.")

        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: result
        )

        let instCode = command.arguments[0] as? String ?? ""

        if !instCode.isEmpty {
            mHP2 = (mHP2 == nil) ? HP2(institutionCode: instCode) : mHP2
            var cardList = [[String:Any]]()

            if let cards = mHP2?.getCards()
            {
                Hp2AppleLog.i("HP2CordovaPlugin", "has \(cards.count) cards")

                for card in cards
                {
                    Hp2AppleLog.i("HP2CordovaPlugin", "\(card.getCardId()), \(card.getDeviceName()), \(card.getOrganizationName())")

                    let cardDic = cardToDic(card: card)
                    cardList.append(cardDic)
                }

                result = toJson(method: "getCards", data: ["cardList":cardList], detail: "", error: false, message: "")

                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: result
                )
            }
            else
            {
              result = toJson(method: "getCards", data: ["cardList":[]], detail: "getCards-PassLibrary NOT available", error: true, message: "Could not load card list")

                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: result
                )
            }
        }

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }

    @objc(executeProvisioning:)
    func executeProvisioning(command: CDVInvokedUrlCommand) {
        var result = toJson(method: "executeProvisioning", data: [:], detail: "", error: true, message: "Invalid parameter.")

        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: result
        )

        let instCode = command.arguments[0] as? String ?? ""
        let cardholderName = command.arguments[1] as? String ?? ""
        let panSuffix = command.arguments[2] as? String ?? ""
        let cardDescr = command.arguments[3] as? String ?? ""
        let panId = command.arguments[4] as? String ?? ""
        let pnp = command.arguments[5] as? String ?? ""
        let pushRecId = command.arguments[6] as? String ?? ""

        if !instCode.isEmpty &&
            !cardholderName.isEmpty &&
            !panSuffix.isEmpty &&
            !cardDescr.isEmpty &&
            !pnp.isEmpty &&
            !pushRecId.isEmpty {
            mHP2 = (mHP2 == nil) ? HP2(institutionCode: instCode) : mHP2

            DispatchQueue.main.async {
                do
                {

                  let vc = UIApplication.getTopViewController()
                  self.provisioningEvents.cmdDelegate = self.commandDelegate
                  self.provisioningEvents.command = command
                  try self.mHP2?.executeProvisioning(parentViewController: vc!,
                                                institutionCode: instCode,
                                                cardholderName: cardholderName,
                                                panSuffix: panSuffix,
                                                cardDescr: cardDescr,
                                                panId: panId,
                                                pnp: pnp,
                                                pushRecId: pushRecId,
                                                     events: self.provisioningEvents)

                }
                catch let hpe as HP2Exception
                {
                  result = "{\"method\":\"executeProvisioning\",\"data\":\"{}\",\"detail\":\"\(hpe.getError())\",\"error\":true,\"message\":\"\(hpe.getMessage())\"}";

                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: result
                    )

                    self.commandDelegate!.send(
                        pluginResult,
                        callbackId: command.callbackId
                    )
                    print("🔴 HP2Exception code=\(hpe.getError()), message=\(hpe.getMessage())")
                }
                catch let e as NSError
                {
                  result = "{\"method\":\"executeProvisioning\",\"data\":\"{}\",\"detail\":\"\(e.debugDescription)\",\"error\":true,\"message\":\"Unexpected error\"}";

                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: result
                    )

                    self.commandDelegate!.send(
                        pluginResult,
                        callbackId: command.callbackId
                    )
                    print("🔴 HP2Exception code=\(String(describing: pluginResult)), message=\(e.debugDescription))")
                }
            }
        } else {

            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }

    @objc(executeProvisioningOfEncryptedCard:)
    func executeProvisioningOfEncryptedCard(command: CDVInvokedUrlCommand) {
        var result = toJson(method: "executeProvisioningOfEncryptedCard", data: [:], detail: "", error: true, message: "Invalid parameter.")

        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: result
        )

        let instCode = command.arguments[0] as? String ?? ""
        let cardholderName = command.arguments[1] as? String ?? ""
        let panSuffix = command.arguments[2] as? String ?? ""
        let cardDescr = command.arguments[3] as? String ?? ""
        let panId = command.arguments[4] as? String ?? ""
        let pnp = command.arguments[5] as? String ?? ""
        let encCard = command.arguments[6] as? String ?? ""

        if !instCode.isEmpty &&
            !cardholderName.isEmpty &&
            !panSuffix.isEmpty &&
            !cardDescr.isEmpty &&
            !pnp.isEmpty &&
            !encCard.isEmpty {
            mHP2 = (mHP2 == nil) ? HP2(institutionCode: instCode) : mHP2

            DispatchQueue.main.async {
                do
                {

                  let vc = UIApplication.getTopViewController()
                  self.provisioningEvents.cmdDelegate = self.commandDelegate
                  self.provisioningEvents.command = command
                  try self.mHP2?.executeProvisioningOfEncryptedCard(parentViewController: vc!,
                                                institutionCode: instCode,
                                                cardholderName: cardholderName,
                                                panSuffix: panSuffix,
                                                cardDescr: cardDescr,
                                                panId: panId,
                                                pnp: pnp,
                                                encCard: encCard,
                                                     events: self.provisioningEvents)

                }
                catch let hpe as HP2Exception
                {
                  result = "{\"method\":\"executeProvisioningOfEncryptedCard\",\"data\":\"{}\",\"detail\":\"\(hpe.getError())\",\"error\":true,\"message\":\"\(hpe.getMessage())\"}";

                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: result
                    )

                    self.commandDelegate!.send(
                        pluginResult,
                        callbackId: command.callbackId
                    )
                }
                catch let e as NSError
                {
                  result = "{\"method\":\"executeProvisioningOfEncryptedCard\",\"data\":\"{}\",\"detail\":\"\(e.debugDescription)\",\"error\":true,\"message\":\"Unexpected error\"}";

                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR,
                        messageAs: result
                    )

                    self.commandDelegate!.send(
                        pluginResult,
                        callbackId: command.callbackId
                    )
                }
            }
        } else {

            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }

    @objc(saveDataToKeychain:)
    func saveDataToKeychain(command: CDVInvokedUrlCommand) {
        let data = command.arguments[0] as? String ?? ""
        let dkey = command.arguments[1] as? String ?? ""

        var resultStatus: CDVCommandStatus = .error
        var resultMsg = "Invalid parameters"

        if !data.isEmpty && !dkey.isEmpty {
            let saved = CoreDataStack.shared.saveDataToKeychainPlugin(data, dkey: dkey)
            if saved {
                resultStatus = .ok
                resultMsg = "Saved successfully"
            } else {
                resultMsg = "Error saving in Keychain"
            }
        }

        let pluginResult = CDVPluginResult(status: resultStatus, messageAs: resultMsg)
        self.commandDelegate?.send(pluginResult, callbackId: command.callbackId)
    }

    func toJson(method:String, data:[String:Any], detail:String, error:Bool, message:String) -> String
    {
        let dataToJson = ["method" : method, "data" : data , "detail" : detail, "error" : error, "message" : message] as [String : Any]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataToJson, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print(jsonString ?? "JSON Error")
            return jsonString ?? ""

        } catch {
            print("{\"method\":\"\(method)\",\"data\":\"{}\",\"detail\":\"\",\"error\":true,\"message\":\"JSON result parce error\"}")
            return "{\"method\":\"\(method)\",\"data\":\"{}\",\"detail\":\"\",\"error\":true,\"message\":\"JSON result parce error\"}";
        }
    }

    func toCardDataModel(jsonString:String) -> [CardDataModel]
    {
      Hp2AppleLog.i("HP2AppleSDKTest", "jsonString: \(jsonString)")
      var cardData = [CardDataModel]()

      if let jsonData = jsonString.data(using: .utf8) {
          do {
              if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                  for jsonObject in jsonArray {
                      if let cardHolderName = jsonObject["cardHolderName"] as? String,
                         let cardId = jsonObject["cardId"] as? String,
                         let cardImageBase64 = jsonObject["cardImageBase64"] as? String,
                         let lastFourDigits = jsonObject["lastFourDigits"] as? String,
                         let localizedDescription = jsonObject["localizedDescription"] as? String,
                         let paymentNetwork = jsonObject["paymentNetwork"] as? String,
                         let cardType = jsonObject["cardType"] as? String {

                        Hp2AppleLog.i("HP2AppleSDKTest", "cardHolderName: \(cardHolderName)")
                        Hp2AppleLog.i("HP2AppleSDKTest", "cardId: \(cardId)")
                        Hp2AppleLog.i("HP2AppleSDKTest", "cardImageBase64: \(cardImageBase64)")
                        Hp2AppleLog.i("HP2AppleSDKTest", "lastFourDigits: \(lastFourDigits)")
                        Hp2AppleLog.i("HP2AppleSDKTest", "localizedDescription: \(localizedDescription)")
                        Hp2AppleLog.i("HP2AppleSDKTest", "paymentNetwork: \(paymentNetwork)")
                        Hp2AppleLog.i("HP2AppleSDKTest", "cardType: \(cardType)")
                        let cardToAdd = CardDataModel(cardHolderName: cardHolderName,
                                                      cardID: cardId,
                                                      cardImageBase64: cardImageBase64,
                                                      lastFourDigits: lastFourDigits,
                                                      localizedDescription: localizedDescription,
                                                      paymentNetwork: paymentNetwork,
                                                      cardType: cardType)
                        cardData.append(cardToAdd)
                      }
                  }
              }
          } catch {
              print("Erro ao processar JSON: \(error)")
          }
      }

      return cardData
    }

    private func cardToDic(card:Card) -> [String : Any]
    {
        let cardDic : [String : Any] = ["cardId" : card.getCardId(),
        "cardType" : (card.getCardType() as? String) ?? "",
        "serialNumber" : card.getSerialNumber(),
        "deviceName" : card.getDeviceName(),
        "icon" : "Base64Image...",
        "organizationName": card.getOrganizationName(),
        "relevantDate" : dateToStr(card.getRelevantDate()),
        "panId" : card.getPanId() ?? "",
        "panLastFour" : card.getPanLastFour() ?? "",
        "tokenId" : card.getTokenId() ?? "",
        "tokenLastFour" : card.getTokenLastFour() ?? "",
        "isRemote" : card.getIsRemote() ? true : false,
        "activationState" : parseCardState(state: card.getActivationState().rawValue)
        ]
        return cardDic
    }

    private func dateToStr(_ date:Date?) -> String
    {
        if let d = date
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return dateFormatter.string(from: d)

        }
        return ""
    }

    private func parseCardState(state:Int) -> String
    {
        switch state
        {
            case 0: return "ACTIVATED"
            case 1: return "REQUIRES_ACTIVATION"
            case 2: return "ACTIVATING"
            case 3: return "SUSPENDED"
            case 4: return "DEACTIVATED"
        default:
            return ""
        }
    }
}

class ProvisioningEvents: CommEvents
{
    var cmdDelegate: CDVCommandDelegate?
    var command: CDVInvokedUrlCommand?

    override func onPreExecute()
    {
    }
    override func onPostExecute(result: HP2AppleSDK.CommEventResult)
    {
        var pluginResult: CDVPluginResult

        if (result.getResult() == HP2Errors.SUCCESS &&
            result.getResultObject() is Card)
        {
            let card = result.getResultObject() as! Card
            let receivedCard = cardToDic(card: card)

            let result = toJson(method: "executeProvisioning", data: receivedCard, detail: "", error: false, message: "")

            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: result
            )
        }
        else
        {
            let result = toJson(method: "executeProvisioning", data: [:], detail: "Error code: \(result.getResult())", error: true, message: result.getMessage())

              pluginResult = CDVPluginResult(
                  status: CDVCommandStatus_ERROR,
                  messageAs: result
              )
        }

        self.cmdDelegate?.send(
            pluginResult,
            callbackId: self.command?.callbackId
        )
    }

    func toJson(method:String, data:[String:Any], detail:String, error:Bool, message:String) -> String
    {
        let dataToJson = ["method" : method, "data" : data , "detail" : detail, "error" : error, "message" : message] as [String : Any]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataToJson, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print(jsonString ?? "JSON Error")
            return jsonString ?? ""

        } catch {
            print("{\"method\":\"\(method)\",\"data\":\"{}\",\"detail\":\"\",\"error\":true,\"message\":\"JSON result parce error\"}")
            return "{\"method\":\"\(method)\",\"data\":\"{}\",\"detail\":\"\",\"error\":true,\"message\":\"JSON result parce error\"}";
        }
    }

    private func cardToDic(card:Card) -> [String : Any]
    {
        let cardDic : [String : Any] = ["cardId" : card.getCardId(),
        "cardType" : card.getCardType() ?? "",
        "serialNumber" : card.getSerialNumber(),
        "deviceName" : card.getDeviceName(),
        "icon" : "Base64Image...",
        "organizationName": card.getOrganizationName(),
        "relevantDate" : dateToStr(card.getRelevantDate()),
        "panId" : card.getPanId() ?? "",
        "panLastFour" : card.getPanLastFour() ?? "",
        "tokenId" : card.getTokenId() ?? "",
        "tokenLastFour" : card.getTokenLastFour() ?? "",
        "isRemote" : card.getIsRemote() ? true : false,
        "activationState" : parseCardState(state: card.getActivationState().rawValue)
        ]
        return cardDic
    }

    func dateToStr(_ date:Date?) -> String
    {
        if let d = date
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return dateFormatter.string(from: d)

        }
        return ""
    }

    private func parseCardState(state:Int) -> String
    {
        switch state
        {
            case 0: return "ACTIVATED"
            case 1: return "REQUIRES_ACTIVATION"
            case 2: return "ACTIVATING"
            case 3: return "SUSPENDED"
            case 5: return "DEACTIVATED"
        default:
            return ""
        }
    }
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
