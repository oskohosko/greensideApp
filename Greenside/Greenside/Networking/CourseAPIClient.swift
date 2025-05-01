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
      let rawHolesURL = Bundle.main.object(forInfoDictionaryKey: "HOLES_URL")
        as? String,
      let holeUrl = URL(string: "https://\(rawHolesURL)"),
      let courseUrl = URL(string: "https://\(rawCourseURL)")
    else {
      fatalError("API_BASE_URL not set in Info.plist")
    }
    self.coursesURL = courseUrl
    self.holesURL = holeUrl
  }

  // Handles GET requests
//  func get<T: Decodable>(courseId: Int? = nil) async throws -> T {
//    var req = URLRequest(url: coursesURL)
//    if let courseId = courseId {
//      req = URLRequest(url: holesURL.appendingPathComponent("\(courseId).json"))
//    }
//    let (data, _) = try await URLSession.shared.data(for: req)
//    print(data)
//    return try JSONDecoder().decode(T.self, from: data)
//  }

  // Gets the courses
  func getCourses() async throws -> [Course] {
    let req = URLRequest(url: coursesURL)
    let (data, _) = try await URLSession.shared.data(for: req)
    return try JSONDecoder().decode([Course].self, from: data)
  }

  func getHoles(for courseId: Int) async throws -> CourseData {
    let req = URLRequest(
      url: URL(string: "\(holesURL)\(courseId).json")!
    )
    let (data, _) = try await URLSession.shared.data(for: req)
//    print(data)
    let courseData = try JSONDecoder().decode(CourseData.self, from: data)
    print(courseData)
    return courseData
  }

}
