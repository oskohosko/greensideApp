//
//  CoursesView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct CoursesView: View {

  @State private var searchText: String = ""

  @EnvironmentObject private var viewModel: CoursesViewModel
  @EnvironmentObject private var router: Router

  var body: some View {
    NavigationStack(path: $router.coursesPath) {
      ZStack {
        Color.base200.ignoresSafeArea()
        VStack(spacing: 12) {
          Text("Courses")
            .font(.system(size: 36, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.content)
            .padding(.leading, 16)
            .padding(.top, 8)
          HStack {
            SearchBar(text: $searchText)
              .onChange(of: searchText) {
                viewModel.filterCourses(by: searchText)
              }
            Button {
              viewModel.sortCoursesByLocation()
            } label: {
              Image(systemName: "location.magnifyingglass")
                .foregroundStyle(Color(.accentGreen))
                .font(.system(size: 32, weight: .medium))
                .padding(.leading, 4)
            }

          }
          .padding(.horizontal, 8)
          .padding(.bottom, 2)
          CourseList()
            .environmentObject(viewModel)
        }
      }

    }
    .onAppear {
      // Resetting filter and sorting by location
      viewModel.filterCourses(by: "")
      viewModel.sortCoursesByLocation()
    }
  }
}

#Preview {
  CoursesView()
    .environmentObject(CoursesViewModel())
    .environmentObject(Router())
}
