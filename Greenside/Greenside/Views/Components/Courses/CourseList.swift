//
//  CourseList.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import SwiftUI
import CoreLocation

struct CourseList: View {

  @EnvironmentObject private var viewModel: GlobalViewModel

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 16) {
        ForEach(viewModel.filteredCourses) { course in
          CourseCard(course: course).environmentObject(viewModel.locationManager)
        }
      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  CourseList().environmentObject(GlobalViewModel())
}
