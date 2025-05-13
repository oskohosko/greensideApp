//
//  CourseDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

import SwiftUI

enum MapType {
  case standard, satellite
}

struct CourseDetailView: View {
  // The course we are displaying info for
  let course: Course

  @EnvironmentObject private var viewModel: CoursesViewModel
  @State private var mapType: MapType = .standard

  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      VStack(alignment: .leading, spacing: 2) {
        // Course title
        Text(viewModel.selectedCourse?.name ?? "Loading...")
          .font(.system(size: 32, weight: .bold))
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundStyle(.content)
          .padding(.top, 8)
          .padding(.horizontal, 16)

        HStack(spacing: 12) {
          // Badges for par and state
          Badge(
            text: "📍\( viewModel.selectedCourse?.state ?? "Victoria") ",
            colour: .accentGreen,
            size: 10
          )
          Badge(
            text: "🏌️‍♂️ Par \( viewModel.selectedCourse?.par ?? 72) ",
            colour: .lightRed,
            size: 10
          )
        }
        .padding(.horizontal, 16)
        ScrollView {
          VStack(spacing: 4) {
            HStack {
              Text("Holes")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.content)
              Spacer()
              Button(action: {
                // Toggling map type
                if mapType == .standard {
                  mapType = .satellite
                } else {
                  mapType = .standard
                }
              }) {
                Image(
                  systemName: mapType == .satellite
                    ? "globe.americas.fill" : "globe.americas"
                )
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.accentGreen)
              }
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)

            HoleCardList(
              round: nil,
              mapType: mapType
            ).environmentObject(viewModel)
          }
        }

      }
    }
    .onAppear {
      Task {
        do {
          _ = await viewModel.loadHoles(for: course.id)
        }
      }
    }
  }
}

#Preview {
  CourseDetailView(course: testCourse).environmentObject(CoursesViewModel())
}
