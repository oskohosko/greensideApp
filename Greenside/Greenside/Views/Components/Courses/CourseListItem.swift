//
//  CourseListItem.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import CoreLocation
import SwiftUI

struct CourseListItem: View {

  let course: Course
  @EnvironmentObject private var viewModel: CoursesViewModel

  private var distance: String {
    guard let userLocation = viewModel.locationManager.currentLocation else {
      return "Loading..."
    }
    return String(
      format: "%.0f",
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
    NavigationLink(destination: CourseDetailView(course: course).environmentObject(viewModel)) {
      HStack {
        VStack(alignment: .leading, spacing: 3) {
          Text(course.name)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.content)
          HStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
              .foregroundStyle(.accentGreen)
              .fontWeight(.bold)
              .font(.title3)
            Text(distance + "km away")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.content)
              .lineLimit(1)
          }

        }
        Spacer()
        Image(systemName: "info.circle")
          .foregroundStyle(.accentGreen)
          .font(.title)
      }
    }
    .padding()
    .frame(height: 80)
    .background(.base100)
    .cornerRadius(20)
  }
}

#Preview {
  CourseListItem(
    course: testCourse,
  ).environmentObject(CoursesViewModel())
}
