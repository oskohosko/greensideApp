//
//  CourseService.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

import Foundation

class CourseService {
  static let shared = CourseService()
  
  init() {}
  
  func fetchCourses() async throws -> [Course] {
    try await CourseAPIClient.shared.getCourses()
  }
  
  func fetchHoles(for courseId: Int) async throws -> CourseData {
    try await CourseAPIClient.shared.getHoles(for: courseId)
  }
}
