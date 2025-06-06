//
//  CourseCard.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import CoreLocation
import SwiftUI

struct CourseCard: View {

  let course: Course
  @ObservedObject var locationManager: LocationManager
  @EnvironmentObject private var router: Router

  private var distance: String {
    guard let userLocation = locationManager.currentLocation else {
      return "Loading..."
    }
    return String(
      format: "%.2f",
      distanceBetweenPoints(
        first: CLLocationCoordinate2D(
          latitude: course.lat,
          longitude: course.lng
        ),
        second: userLocation.coordinate
      ) / 1000
    )
  }

  var body: some View {
    Button {
      router.navigateToCourse(course)
    } label: {
      VStack {
        Text(course.name)
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(.content)
          .lineLimit(3)

        Divider()
          .frame(height: 1)
          .overlay(
            Rectangle()
              .frame(height: 3)
              .foregroundColor(Color.base200)
              .cornerRadius(10)
          )
        HStack(spacing: 4) {
          Image(systemName: "mappin.circle.fill")
            .foregroundColor(.accentGreen)
            .fontWeight(.bold)
            .font(.subheadline)
          Text(distance + "km")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.content)
            .lineLimit(1)
        }.padding(.top, 4)
      }
    }
    .padding()
    .frame(width: 120)
    .background(.base100)
    .cornerRadius(20)
    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

// Helper function for distance
func distanceBetweenPoints(
  first: CLLocationCoordinate2D,
  second: CLLocationCoordinate2D
) -> CLLocationDistance {

  let location1 = CLLocation(
    latitude: first.latitude,
    longitude: first.longitude
  )
  let location2 = CLLocation(
    latitude: second.latitude,
    longitude: second.longitude
  )

  return location1.distance(from: location2)
}

let testCourse = Course(
  id: 3,
  name: "Albert Park Golf Club",
  lat: -37.848063,
  lng: 144.976116
)

let testLocation = CLLocation(
  latitude: -37.81526056701829,
  longitude: 145.08827251255252
)

#Preview {
  CourseCard(
    course: testCourse,
    locationManager: CoursesViewModel().locationManager
  )
  .environmentObject(Router())
}
