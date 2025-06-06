//
//  CourseList.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import CoreLocation
import SwiftUI

struct CourseCardList: View {
  @EnvironmentObject private var router: Router

  @EnvironmentObject private var viewModel: CoursesViewModel

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 12) {
        ForEach(viewModel.filteredCourses) { course in
          CourseCard(
            course: course,
            locationManager: viewModel.locationManager
          )
          .environmentObject(router)
        }
      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  CourseCardList()
    .environmentObject(CoursesViewModel())
    .environmentObject(Router())
}
