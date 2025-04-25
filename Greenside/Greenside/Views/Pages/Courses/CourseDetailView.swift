//
//  CourseDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

import SwiftUI

struct CourseDetailView: View {

  // The course we are displaying info for
  let course: Course
  @EnvironmentObject var 

  var body: some View {
    NavigationStack {
      ZStack {
        Color.base200.ignoresSafeArea()
        VStack(spacing: 0) {
          // Main content area
          VStack {
            Spacer()
            Text("Main Content Goes Here")
            Spacer()
          }
          .padding()
        }
      }
    }
    // This ensures navbar stays
    .navigationTitle("")
    .navigationBarHidden(true)
    .toolbarBackground(Color(.base100), for: .tabBar)
    .toolbarBackground(.visible, for: .tabBar)
  }
}

#Preview {
  CourseDetailView(course: testCourse)
}
