//
//  AuthViewModel.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

enum AuthPhase: Equatable {
  case checking
  case unauthenticated
  case authenticated(User)
  case error(String)
}

@MainActor
class AuthViewModel: ObservableObject {
  @Published var user: User? = nil

  @Published var firstName: String = ""
  @Published var lastName: String = ""
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var confirmPassword: String = ""

  @Published var phase: AuthPhase = .checking

  private let repo: AuthRepository

  init(repo: AuthRepository = .shared) {
    self.repo = repo
  }

  func handleSignUp() async {
    do {
      try await repo.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        pw: password
      )
      if let user = await repo.currentUser {
        phase = .authenticated(user)
        self.user = user
      }
    } catch {
      phase = .error(error.localizedDescription)
    }

  }

  func handleLogin() async {
    do {
      try await repo.login(email: email, pw: password)
      if let user = await repo.currentUser {
        phase = .authenticated(user)
        self.user = user
      }
    } catch {
      phase = .error(error.localizedDescription)
    }

  }

  func handleLogout() {
    self.user = nil
    Task {
      await repo.logout()
      await MainActor.run { phase = .unauthenticated }
    }

  }
  
  func bootstrap() async {
    phase = .checking
    if await repo.verify() {
      phase = .authenticated(await repo.currentUser!)
    } else {
      phase = .unauthenticated
    }
  }
}

