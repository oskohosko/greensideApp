//
//  AuthViewModel.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
  @Published var user: UserDTO?
  @Published var isAuthenticated: Bool = false
  @Published var isLoading = false
  @Published var loginError: String? = nil
  @Published var isLoggedIn: Bool = false
  @Published var isCheckingAuth: Bool = true

  @Published var firstName: String = ""
  @Published var lastName: String = ""
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var confirmPassword: String = ""

  func handleSignUp(
    firstName: String,
    lastName: String,
    email: String,
    password: String,
  ) async {
    do {
      let user = try await AuthService.shared.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password
      )
      if let token = user.token {
        KeychainHelper.shared.saveToken(token)
      }
      self.user = user
      self.isLoggedIn = true
    } catch {
      self.loginError = error.localizedDescription
      self.isLoggedIn = false
    }
  }

  func handleLogin(email: String, password: String) async {
    do {
      let user = try await AuthService.shared.login(
        email: email,
        password: password
      )
      if let token = user.token {
        KeychainHelper.shared.saveToken(token)
      }
      self.user = user
      self.isLoggedIn = true

    } catch {
      self.loginError = error.localizedDescription
      self.isLoggedIn = false
    }
  }

  func verify() async {
    isCheckingAuth = true

    if let token = KeychainHelper.shared.readToken() {
      do {
        let user = try await AuthService.shared.verifyToken(token: token)
        print(user)
        self.user = user
        self.isLoggedIn = true
        isCheckingAuth = false
      } catch {
        print("Token validation failed: \(error.localizedDescription)")
        isLoggedIn = false
      }

    } else {
      print("No token found")
      isLoggedIn = false

    }
    isCheckingAuth = false
  }

  func logout() async {
    do {
      await self.verify()
      KeychainHelper.shared.deleteToken()
      user = nil
      isLoggedIn = false
      isCheckingAuth = false
    }
    
  }

}
