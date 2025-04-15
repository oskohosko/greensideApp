//
//  AuthViewModel.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

@MainActor
class AuthViewModel: ObservableObject {
  @Published var user: User?
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

  func handleLogin(email: String, password: String) {
    Task {
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
        self.loginError = nil
      } catch {
        self.loginError = error.localizedDescription
        self.isLoggedIn = false
      }
    }
  }

  func verify() async {
    isCheckingAuth = true

    if let token = KeychainHelper.shared.readToken() {
      do {
        let user = try await AuthService.shared.verifyToken(token: token)
        self.user = user
        self.isLoggedIn = true
        isCheckingAuth = false
      } catch {
        isLoggedIn = false
        isCheckingAuth = false
      }
    } else {
      isLoggedIn = false
      isCheckingAuth = false
    }
  }

  func logout() {
    KeychainHelper.shared.deleteToken()
    user = nil
    isLoggedIn = false
    isCheckingAuth = false
    print("Logged out")
    print(isLoggedIn)
    print(user)
  }

}
