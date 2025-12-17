//
//  KeychainHelper.swift
//  Attendance
//
//  Created by POSSIBILITY on 23/04/25.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            if let data = item as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    // MARK: - Save Int
    func saveInt(_ value: Int, forKey key: String) {
        let stringValue = String(value)
        save(stringValue, forKey: key)
    }
    // MARK: - Get Int
    func getInt(forKey key: String) -> Int? {
        if let stringValue = get(forKey: key) {
            return Int(stringValue)
        }
        return nil
    }
    // MARK: - Delete Int
    func deleteInt(forKey key: String) {
        delete(forKey: key)
    }
}
