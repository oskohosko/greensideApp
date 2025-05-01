//
//  CourseRepository.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

actor CourseRepository {
  static let shared = CourseRepository()
  private let courseService = CourseService()
  
  private(set) var courses: [Course] = []
  private(set) var holes: [Hole] = []
  
  
  
}
