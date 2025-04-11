//
//  AuthService.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

class AuthService {
  static let shared = AuthService()
  
  private init() {}
  
  // Login method
  func login(email: String, password: String) async throws -> User {
    // TODO Login
    if let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String {
      
      print(apiBaseURL)
      // Ensuring valid URL
      guard let url = URL(string: "http://\(apiBaseURL)/login") else {
        print("url error")
        throw URLError(.badURL)
      }
      
      // Making the request
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      // Sending email password
      let body = ["email": email, "password": password]
      request.httpBody = try JSONEncoder().encode(body)
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
        print(response)
        throw URLError(.badServerResponse)
      }
      
      let user = try JSONDecoder().decode(User.self, from: data)
      
      print(user)
      print("Success!")
      return user
    } else {
      print("Bad url")
      throw URLError(.badURL)
    }
    
  }
  
  // Signup method
  func signup(email: String, password: String) async throws {
    // TODO Sign up
  }
  
  // Logout method
  func logout() async throws {
    // TODO Log out
  }
}
