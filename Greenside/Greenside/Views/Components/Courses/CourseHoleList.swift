//
//  HoleCardList.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import SwiftUI

// This presents a list of holes in a course
struct CourseHoleList: View {
  @EnvironmentObject private var viewModel: CoursesViewModel

  @Binding var  mapType: MapType

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      // If we have 18 holes I want two rows one for the front nine and one for the back
      if viewModel.selectedCourse?.holes.count == 18 {
        ForEach(0..<2) { index in
          VStack(alignment: .leading, spacing: 4) {
            Text(index == 0 ? "Front Nine" : "Back Nine")
              .font(.caption)
              .foregroundColor(.base500)
              .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(viewModel.courseHoles[index * 9..<(index + 1) * 9]) {
                  hole in
                  
                  CourseHoleCard(
                    hole: hole,
                    mapType: $mapType
                  ).environmentObject(viewModel)
                }
              }
              .padding(.horizontal)
            }
          }
        }
      } else {
        // Otherwise we show 3 rows.
        ForEach(0..<3) { index in
          let start = index * 3
          let end = min(start + 3, viewModel.courseHoles.count)

          if start < end {
            VStack(alignment: .leading, spacing: 4) {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {

                  ForEach(viewModel.courseHoles[start..<end]) {
                    hole in
                    CourseHoleCard(
                      hole: hole,
                      mapType: $mapType
                    ).environmentObject(viewModel)
                  }
                }
                .padding(.horizontal)
              }
            }
          }

        }
      }
    }
    Spacer().frame(height: 200)
  }
}

#Preview {
  @Previewable @State var mapType: MapType = .standard
  
  CourseHoleList(mapType: $mapType)
    .environmentObject(CoursesViewModel())
}
