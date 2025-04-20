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

  @Published var allCourses: [Course] = []
  @Published var filteredCourses: [Course] = []
  @Published var isLoading: Bool = false

  override init() {
    super.init()

    filteredCourses = allCourses
  }

  // This function loads courses from our API
  func loadCourses() async throws -> [Course] {
    isLoading = true
    // Getting API url
    if let coursesURL = Bundle.main.object(
      forInfoDictionaryKey: "ALL_COURSES_URL"
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
      
//      print(courses)
      isLoading = false
      return courses
    } else {
      throw URLError(.badURL)
    }
  }

}
