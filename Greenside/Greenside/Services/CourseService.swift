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
    try await CourseAPIClient.shared.get()
  }
  
  func fetchHoles(for courseId: Int) async throws -> [Hole] {
    try await CourseAPIClient.shared.get(courseId: courseId)
  }
}
