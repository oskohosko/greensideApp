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
  
  // State for scores
  @Published var scores: [Int: Int] = [:]
  @Published var finalScore: String = ""

  // Flag for changing holes
  @Published var isChangingHole: Bool = false
  @Published var needsMapRefresh: Bool = false

  var canAdvance: Bool {
    !title.trimmingCharacters(in: .whitespaces).isEmpty && selectedCourse != nil
  }

  // Course repository for loading courses
  private let repo = CourseRepository.shared

  // Firebase for saving round
  private let firebase = FirebaseManager.shared
  @Published var isSaving: Bool = false
  @Published var saveError: String?

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

  func saveRound(scores: [Int: Int], finalScore: Int) async {
    guard let course = selectedCourse else {
      saveError = "No course selected"
      return
    }

    guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
      saveError = "Round title is required"
      return
    }

    isSaving = true
    saveError = nil

    // Saving the round
    do {
      try await firebase.saveRound(
        title: title,
        courseName: course.name,
        courseId: course.id,
        roundDate: roundDate,
        holes: allHoles,
        roundShots: roundShots,
        scores: scores,
        finalScore: finalScore
      )
//      resetData()
    } catch {
      saveError = "Failed to save round: \(error.localizedDescription)"
      print("Error saving round: \(error)")
    }
    
    isSaving = false
  }

  func resetData() {
    // Reset UI Input bounds
    title = ""
    selectedCourse = nil
    roundDate = Date()

    // Reset UI State for courses list
    filteredCourses = allCourses
    courseSearch = ""
    isLoading = false

    // Reset UI State for holes
    currentHole = nil
    allHoles = []
    isHolesLoading = false

    // Reset UI State for shots
    roundShots = [:]

    // Reset flags
    isChangingHole = false
    needsMapRefresh = false
    
    // Score
    scores = [:]
    finalScore = ""
  }

}
