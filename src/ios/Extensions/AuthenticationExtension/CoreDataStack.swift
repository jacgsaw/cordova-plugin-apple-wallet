//
//  CoreDataStack.swift
//  Davivienda SuperApp
//
//  Created by JOSE ALEXANDER CRUZ GONZALEZ on 5/06/25.
//

import CoreData

public class CoreDataStack {
    public static let shared = CoreDataStack()

    public let persistentContainer: NSPersistentContainer
    public let appGroupID = "group.com.davivienda.wallet.InAppProvisioningExtension"

    private init() {
        let modelName = "Model"

        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        else {
            print("⚠️ [CoreDataStack] No se encontró el modelo de datos \(modelName).momd.")
            persistentContainer = NSPersistentContainer(name: modelName)
            return
        }

        persistentContainer = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)

        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            print("No se encontró el App Group container")
            return
        }
        let storeURL = containerURL.appendingPathComponent("\(modelName).sqlite")

        let description = NSPersistentStoreDescription(url: storeURL)

        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Error cargando la base de datos: \(error)")
            } else {
                print("✅ CoreData cargada desde: \(storeURL)")
            }
        }
    }

    open func saveDataToKeychainPlugin(_ data: String, dkey: String) -> Bool {
            guard let getData = data.data(using: .utf8) else { return false }
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: dkey,
                kSecAttrAccessGroup as String: appGroupID,
                kSecValueData as String: getData
            ]
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error saving in Keychain: \(status)")
            }
            return status == errSecSuccess
        }

    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    open func readFromKeychain(key: String) -> String? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecAttrAccessGroup as String: appGroupID,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            if status == errSecSuccess, let data = result as? Data {
                return String(data: data, encoding: .utf8)
            }
            return nil
        }
}
