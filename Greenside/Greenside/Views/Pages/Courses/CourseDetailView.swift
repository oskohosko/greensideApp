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

  @EnvironmentObject private var viewModel: CoursesViewModel

  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      VStack(alignment: .leading, spacing: 2) {
        // Course title
        Text(viewModel.selectedCourse?.name ?? "Loading...")
          .font(.system(size: 38, weight: .bold))
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundStyle(.content)
          .padding(.top, 8)
          .padding(.horizontal, 16)

        HStack(spacing: 12) {
          // Badges for par and state
          Badge(
            text: "📍\( viewModel.selectedCourse?.state ?? "Victoria") ",
            colour: .accentGreen
          )
          Badge(
            text: "🏌️‍♂️ Par \( viewModel.selectedCourse?.par ?? 72) ",
            colour: .lightRed
          )
        }
        .padding(.horizontal, 16)
        ScrollView {
          VStack(spacing: 4) {
            Text("Holes")
              .font(.system(size: 32, weight: .bold))
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(.content)
              .padding(.top, 8)
              .padding(.horizontal, 16)
            HoleCardList().environmentObject(viewModel)
          }
        }

      }
    }
    .onAppear {
      Task {
        do {
          _ = await viewModel.loadHoles(for: course)
        }
      }
    }
  }
}

#Preview {
  CourseDetailView(course: testCourse).environmentObject(CoursesViewModel())
}
