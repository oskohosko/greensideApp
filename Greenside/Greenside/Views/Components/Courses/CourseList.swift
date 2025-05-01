//
//  CourseList.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import SwiftUI

struct CourseList: View {
  @EnvironmentObject private var viewModel: GlobalViewModel
  var body: some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: 4) {
        ForEach(viewModel.filteredCourses) { course in
          CourseListItem(
            course: course
          ).environmentObject(viewModel.locationManager)
        }
      }
      .padding(.horizontal, 8)
    }
  }
}

#Preview {
  CourseList().environmentObject(GlobalViewModel())
}
