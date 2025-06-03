//
//  RoundCreationVM.swift
//  Greenside
//
//  Created by Oskar Hosken on 27/5/2025.
//

import Foundation
import SwiftUI

@MainActor
final class RoundCreationVM: ObservableObject {

  // UI Input bounds
  @Published var title: String = ""
  @Published var selectedCourse: Course? = nil
  @Published var roundDate: Date = Date()
  
  // UI State for courses list
  @Published var allCourses: [Course] = []
  @Published var filteredCourses: [Course] = []
  @Published var courseSearch = ""
  @Published var isLoading: Bool = false
  
  // UI State for holes
  @Published var currentHole: Hole? = nil
  @Published var allHoles: [Hole] = []
  @Published var isHolesLoading: Bool = false
  
  // UI State for shots (hole.num : [Shot])
  @Published var roundShots: [Int: [Shot]] = [:]
  
  // Flag for changing holes
  @Published var isChangingHole: Bool = false
  @Published var needsMapRefresh: Bool = false

  var canAdvance: Bool {
    !title.trimmingCharacters(in: .whitespaces).isEmpty && selectedCourse != nil
  }

  // Course repository for loading courses
  private let repo = CourseRepository.shared

  // This function loads courses from our API
  func loadCourses() async {
    guard allCourses.isEmpty else {
      return
    }
    isLoading = true
    do {
      allCourses = try await repo.loadCourses()
      filteredCourses = allCourses
    } catch {
      print("Course loading failed:", error)
    }
    isLoading = false
  }
  
  func loadHoles(for courseId: Int) async {
    isHolesLoading = true
    do {
      let courseData = try await repo.loadHoles(for: courseId)
      self.allHoles = courseData.holes
      self.currentHole = allHoles.first
    } catch {
      print("Holes loading failed:", error)
    }
    isHolesLoading = false
  }

  func filterCourses(by keyword: String) {
    // Filtering function when searching for a course.
    if keyword.isEmpty {
      filteredCourses = allCourses
    } else {
      filteredCourses = allCourses.filter {
        $0.name.lowercased().contains(keyword.lowercased())
      }
    }
  }
  
  // Function that returns the previous hole if it exists
  func previousHole(current: Int) -> Hole? {
    guard let idx = allHoles.firstIndex(where: { $0.num == current }),
      idx > 0
    else { return nil }
    return allHoles[idx - 1]
  }

  // Returns the next hole if it exists
  func nextHole(current: Int) -> Hole? {
    guard let idx = allHoles.firstIndex(where: { $0.num == current }),
      idx < allHoles.count - 1
    else { return nil }
    return allHoles[idx + 1]
  }

}
