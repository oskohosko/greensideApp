//
//  GlobalViewModel.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import CoreLocation
import Foundation

enum ListError: Error {
  case invalidURL
  case invalidServerResponse
}

@MainActor
class GlobalViewModel: ObservableObject {
  // Global Location Manager
  @Published var locationManager = LocationManager()
  // Loading flag
  @Published var isLoading: Bool = false
  
  // UI Lists
  @Published var allCourses: [Course] = []
  @Published var filteredCourses: [Course] = []
  @Published var courseHoles: [Hole] = []
  
  @Published var selectedCourse: Course?
  @Published var selectedHole: Hole?
  
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
  
  func loadHoles(for course: Course) async {
    selectedCourse = course
    isLoading = true
    do {
      courseHoles = try await repo.loadHoles(for: course.id)
      selectedHole = courseHoles.first
    } catch {
      print("Holes loading failed:", error)
    }
    isLoading = false
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

  func sortCoursesByLocation() {
    guard let userLocation = locationManager.currentLocation else {
      return
    }

    filteredCourses = filteredCourses.sorted { course1, course2 in
      // Getting locations and distances
      let courseLoc1 = CLLocation(latitude: course1.lat, longitude: course1.lng)
      let courseLoc2 = CLLocation(latitude: course2.lat, longitude: course2.lng)
      let distance1 = userLocation.distance(from: courseLoc1)
      let distance2 = userLocation.distance(from: courseLoc2)

      // Sorting by course that is closest to user
      return distance1 < distance2
    }
  }
}
