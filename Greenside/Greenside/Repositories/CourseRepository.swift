//
//  CourseRepository.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

actor CourseRepository {
  static let shared = CourseRepository()
  private let courseService = CourseService()
  
  // UI State
  private var coursesCache: [Course] = []
  private var holesCache: [Int: [Hole]] = [:]
  
  // Fetching courses
  func loadCourses() async throws -> [Course] {
    // Don't load courses if already loaded
    if !coursesCache.isEmpty {
      return coursesCache
    }
    // Calling service to make the fetch
    let courses = try await courseService.fetchCourses()
    return courses
  }
  
  // Fetching holes for course
  func loadHoles(for courseId: Int) async throws -> [Hole] {
    // Checking if holes already loaded
    if let cached = holesCache[courseId] {
      return cached
    }
    // If not, laod them
    let fetchedHoles: [Hole] = try await courseService.fetchHoles(for: courseId)
    holesCache[courseId] = fetchedHoles
    return fetchedHoles
    
  }
  
}
