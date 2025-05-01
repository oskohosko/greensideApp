//
//  CourseList.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import CoreLocation
import SwiftUI

struct CourseCardList: View {

  @EnvironmentObject private var viewModel: GlobalViewModel
  @EnvironmentObject private var router: Router

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 16) {
        ForEach(viewModel.filteredCourses) { course in
          CourseCard(
            course: course
          ).environmentObject(viewModel.locationManager)
        }
      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  CourseCardList().environmentObject(GlobalViewModel())
    .environmentObject(Router())
}
