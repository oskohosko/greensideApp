//
//  CourseAPIClient.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

import Foundation

struct CourseAPIClient {
  static let shared = CourseAPIClient()
  private let coursesURL: URL
  private var holesURL: URL

  private init() {
    guard
      let rawCourseURL = Bundle.main.object(forInfoDictionaryKey: "COURSES_URL")
        as? String,
      let rawHolesURL = Bundle.main.object(forInfoDictionaryKey: "HOLES_URL") as? String,
      let holeUrl = URL(string: "http://\(rawHolesURL)"),
      let courseUrl = URL(string: "http://\(rawCourseURL)")
    else {
      fatalError("API_BASE_URL not set in Info.plist")
    }
    self.coursesURL = courseUrl
    self.holesURL = holeUrl
  }

  // Handles GET requests
  func get<T: Decodable>(courseId: Int? = nil) async throws -> T {
    var req = URLRequest(url: coursesURL)
    if let courseId = courseId {
      var req = URLRequest(url: holesURL.appendingPathComponent("\(courseId).json"))
    }
    let (data, _) = try await URLSession.shared.data(for: req)
    return try JSONDecoder().decode(T.self, from: data)
  }

}
