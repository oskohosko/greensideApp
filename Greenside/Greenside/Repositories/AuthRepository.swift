//
//  AuthRepository.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

actor AuthRepository {
  static let shared = AuthRepository()
  private let authService = AuthService()
  private let keychain = KeychainHelper.shared

  private(set) var currentUser: User? = nil

  func login(email: String, pw: String) async throws {
    let dto = try await authService.login(email: email, password: pw)
    persist(dto)
    
  }

  func signup(firstName: String, lastName: String, email: String, pw: String)
    async throws
  {
    let dto = try await authService.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: pw
    )
    persist(dto)
  }

  func verify() async -> Bool {
    if let token = keychain.readToken() {
      do {
        let dto = try await authService.verifyToken(token: token)
        persist(dto)
        return true
      } catch {
        return false
      }
    } else {
      return false
    }

  }

  func logout() {
    keychain.deleteToken()
    currentUser = nil
  }

  private func persist(_ dto: UserDTO) {
    if let t = dto.token {
      keychain.saveToken(t)
      currentUser = dto.asDomain
    }
  }
}
