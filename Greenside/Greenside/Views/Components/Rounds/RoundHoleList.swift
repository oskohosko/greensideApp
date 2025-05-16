//
//  RoundHoleList.swift
//  Greenside
//
//  Created by Oskar Hosken on 16/5/2025.
//

import SwiftUI

// This presents a list of holes in a course
struct RoundHoleList: View {
  @EnvironmentObject private var coursesViewModel: CoursesViewModel

  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility

  let mapType: MapType
  
  // All of the shots for the round
  let shotsByHole: [Int: [Shot]]

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      // If we have 18 holes I want two rows one for the front nine and one for the back
      if coursesViewModel.selectedCourse?.holes.count == 18 {
        ForEach(0..<2) { index in
          VStack(alignment: .leading, spacing: 4) {
            Text(index == 0 ? "Front Nine" : "Back Nine")
              .font(.caption)
              .foregroundColor(.base500)
              .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(
                  coursesViewModel.courseHoles[index * 9..<(index + 1) * 9]
                ) {
                  hole in

                  RoundHoleCard(
                    hole: hole,
                    shots: shotsByHole[hole.num] ?? [],
                    mapType: mapType
                  )
                  .environmentObject(coursesViewModel)
                  .environmentObject(roundsViewModel)
                  .environmentObject(tabBarVisibility)
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
          let end = min(start + 3, coursesViewModel.courseHoles.count)

          if start < end {
            VStack(alignment: .leading, spacing: 4) {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {

                  ForEach(coursesViewModel.courseHoles[start..<end]) {
                    hole in
                    RoundHoleCard(
                      hole: hole,
                      shots: shotsByHole[hole.num] ?? [],
                      mapType: mapType
                    )
                    .environmentObject(coursesViewModel)
                    .environmentObject(roundsViewModel)
                    .environmentObject(tabBarVisibility)
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
  RoundHoleList(mapType: .standard, shotsByHole: [:])
    .environmentObject(CoursesViewModel())
    .environmentObject(RoundsViewModel())
    .environmentObject(TabBarVisibility())
    
}
