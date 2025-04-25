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
class GlobalViewModel: NSObject, ObservableObject, Observable {
  // Global Location Manager
  @Published var locationManager = LocationManager()
  // Loading flag
  @Published var isLoading: Bool = false

  // Courses
  @Published var allCourses: [Course] = []
  @Published var filteredCourses: [Course] = []

  // Holes
  @Published var selectedCourse: Course?
  @Published var courseHoles: [Hole] = []
  @Published var selectedHole: Hole?

  override init() {
    super.init()

    filteredCourses = allCourses
  }

  // This function loads courses from our API
  func loadCourses() async throws -> [Course] {
    isLoading = true
    // Getting API url
    if let coursesURL = Bundle.main.object(
      forInfoDictionaryKey: "COURSES_URL"
    ) as? String {

      // Ensuring its a valid url
      guard let url = URL(string: "https://\(coursesURL)") else {
        print("url error")
        throw URLError(.badURL)
      }

      // Making the request
      let request = URLRequest(url: url)

      let (data, _) = try await URLSession.shared.data(for: request)
      // Decoding into list of courses
      let courses = try JSONDecoder().decode([Course].self, from: data)
      // Updating published variable
      self.allCourses = courses
      self.filteredCourses = courses

      //      print(courses)
      isLoading = false
      return courses
    } else {
      throw URLError(.badURL)
    }
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

  func loadHoles(courseId: Int) async throws -> [Hole] {
    isLoading = true
    // Getting API url
    if let holesURL = Bundle.main.object(
      forInfoDictionaryKey: "HOLES_URL"
    ) as? String {

      // Ensuring its a valid url
      guard let url = URL(string: "https://\(holesURL)\(courseId).json") else {
        print("url error")
        throw URLError(.badURL)
      }

      // Making the request
      let request = URLRequest(url: url)

      let (data, _) = try await URLSession.shared.data(for: request)
      // Decoding into list of holes
      let holes = try JSONDecoder().decode([Hole].self, from: data)
      // Updating published variable
      self.courseHoles = holes

      print(holes)
      isLoading = false
      return holes
    } else {
      throw URLError(.badURL)
    }
  }

}
