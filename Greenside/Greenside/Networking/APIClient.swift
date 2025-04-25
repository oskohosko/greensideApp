//
//  APIClient.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

import Foundation

struct APIClient {
  static let shared = APIClient()
  private let baseURL: URL

  private init() {
    guard
      let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL")
        as? String,
      let url = URL(string: "http://\(raw)/")
    else {
      fatalError("API_BASE_URL not set in Info.plist")
    }
    self.baseURL = url
  }

  // Handles POST requests
  func post<T: Decodable>(_ path: String, body: Encodable) async throws -> T {
    var req = URLRequest(url: baseURL.appendingPathComponent(path))
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue("mobile", forHTTPHeaderField: "X-Client-Type")
    req.httpBody = try JSONEncoder().encode(body)

    let (data, res) = try await URLSession.shared.data(for: req)
    guard let http = res as? HTTPURLResponse, 200..<300 ~= http.statusCode
    else {
      throw URLError(.badServerResponse)
    }

    return try JSONDecoder().decode(T.self, from: data)
  }

  // Handles GET requests
  func get<T: Decodable>(
    _ path: String,
    headers: [String: String] = [:]
  ) async throws -> T {
    var req = URLRequest(url: baseURL.appendingPathComponent(path))
    headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
    let (data, _) = try await URLSession.shared.data(for: req)
    return try JSONDecoder().decode(T.self, from: data)
  }

}
