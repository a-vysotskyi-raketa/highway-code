//
//  KeychainCredentialsStorage.swift
//  Cash Collection
//
//  Created by Andrew Visotskyy on 12/7/18.
//  Copyright © 2018 Euro Exchange Securities. All rights reserved.
//

import Security
import LocalAuthentication

class KeychainCredentialsStorage: CredentialsStorage {

    private let service: String

    init(service: String) {
        self.service = service
    }

    // MARK: - CredentialsStorage

    var credentials: Credentials? {
        get { return readCredentials() }
        set { setCredentials(credentials: newValue) }
    }

    // MARK: -

    private func setCredentials(credentials: Credentials?) {
        if let credentials = credentials {
            storeCredentials(credentials)
        } else {
            removeCredentials()
        }
    }

    private func storeCredentials(_ credentials: Credentials) {
        let account = credentials.userId
        let password = Data(credentials.accessToken.utf8)
        // Create an access control instance that dictates how the item can be read later.
        let access = SecAccessControlCreateWithFlags(
            nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil
        )
        // Build the query for use in the add operation.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecAttrAccessControl as String: access as Any,
            kSecValueData as String: password
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            NSLog("Failed to store credentials: \(description(for: status))")
            return
        }
        NSLog("Successfully stored credentials.")
    }

    /// Reads the stored credentials for the given server.
    private func readCredentials() -> Credentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?

        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            NSLog("Unable to retieve credentials: \(description(for: status))")
            return nil
        }

        guard let existingItem = item as? [String: Any],
            let accessTokenData = existingItem[kSecValueData as String] as? Data,
            let accessToken = String(data: accessTokenData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        else {
            NSLog("Unable to retieve credentials: \(description(for: status))")
            return nil
        }
        return Credentials(userId: account, accessToken: accessToken)
    }

    private func removeCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            NSLog("Unable to remove credentials: \(description(for: status))")
            return
        }
        NSLog("Successfully removed credentials.")
    }

    private func description(for status: OSStatus) -> String {
        if #available(iOS 11.3, *) {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        }
        return "Unknown error."
    }

}
