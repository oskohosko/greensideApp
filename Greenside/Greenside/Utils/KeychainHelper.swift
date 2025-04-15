//
//  KeychainHelper.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation
import Security

class KeychainHelper {
  static let shared = KeychainHelper()

  // Writes to Keychain
  func save(_ data: Data, service: String, account: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: data,
    ]
    // Deleting any existing item
    SecItemDelete(query as CFDictionary)
    // Adding the new item
    SecItemAdd(query as CFDictionary, nil)
  }

  // Read from Keychain
  func read(service: String, account: String) -> Data? {
    // TODO - Read from Keychain
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &item)
    return item as? Data
  }

  func delete(service: String, account: String) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    SecItemDelete(query as CFDictionary)
  }

  func saveToken(_ token: String) {
    if let data = token.data(using: .utf8) {
      save(data, service: "auth", account: "jwt")
    }
  }

  func readToken() -> String? {
    guard let data = read(service: "auth", account: "jwt") else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }
  
  func deleteToken() {
    delete(service: "auth", account: "jwt")
  }
}
