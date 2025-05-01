//
//  AuthService.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

class AuthService {
  static let shared = AuthService()

  init() {}

  func login(email: String, password: String) async throws -> UserDTO {
    try await AuthAPIClient.shared.post("login", body: ["email": email, "password": password])
  }
  
  func signup(firstName: String, lastName: String, email: String, password: String) async throws -> UserDTO {
    try await AuthAPIClient.shared.post("signup", body: ["firstName": firstName, "lastName": lastName, "email": email, "password": password])
  }
  
  func verifyToken(token: String) async throws -> UserDTO {
    try await AuthAPIClient.shared.get("check", headers: ["Authorization" : "Bearer \(token)", "X-Client-Type": "mobile"])
  }
}
