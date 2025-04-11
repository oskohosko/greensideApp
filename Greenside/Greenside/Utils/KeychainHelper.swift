//
//  KeychainHelper.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

class KeychainHelper {
  static let shared = KeychainHelper()
  
  // Writes to Keychain
  func save(_ data: Data, service: String, account: String) {
    // TODO - write to Keychain
  }
  
  // Read from Keychain
  func read(service: String, account: String) -> Data? {
    // TODO - Read from Keychain
    return nil
  }
  
  func delete(service: String, account: String) {
    // TODO - Remove the token
  }
}
