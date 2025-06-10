//
//  CoursesViewModel.swift
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
class CoursesViewModel: ObservableObject {
  // Global Location Manager
  @Published var locationManager = LocationManager()
  // Loading flag
  @Published var isLoading: Bool = false

  // UI Lists
  @Published var allCourses: [Course] = []
  @Published var filteredCourses: [Course] = []
  @Published var courseHoles: [Hole] = []
  @Published var filteredHoles: [Hole] = []

  @Published var selectedCourse: CourseData?
  @Published var selectedHole: Hole?

  private let repo = CourseRepository.shared

  // Requests location
  func requestLocation() {
    locationManager.requestCurrentLocation { [weak self] location in
      guard self != nil else {
        return
      }
    }
  }

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
    isLoading = true
    do {
      let courseData = try await repo.loadHoles(for: courseId)
      selectedCourse = courseData
      courseHoles = courseData.holes
      filteredHoles = courseHoles
//      selectedHole = courseHoles.first
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

  func filterHoles(by keyword: String) {
    if keyword.isEmpty {
      filteredHoles = courseHoles
    } else {
      filteredHoles = courseHoles.filter {
        "hole \($0.num)".contains(keyword.lowercased())
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

  func previousHole(current: Hole) -> Hole? {
    guard let idx = courseHoles.firstIndex(where: { $0.id == current.id }),
      idx > 0
    else { return nil }
    return courseHoles[idx - 1]
  }

  func nextHole(current: Hole) -> Hole? {
    guard let idx = courseHoles.firstIndex(where: { $0.id == current.id }),
      idx < courseHoles.count - 1
    else { return nil }
    return courseHoles[idx + 1]
  }
}
