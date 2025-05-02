//
//  HoleCardList.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import SwiftUI

struct HoleCardList: View {
  @EnvironmentObject private var viewModel: CoursesViewModel

  let mapType: MapType

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      if viewModel.selectedCourse?.holes.count == 18 {
        ForEach(0..<2) { index in
          VStack(alignment: .leading, spacing: 4) {
            Text(index == 0 ? "Front Nine" : "Back Nine")
              .font(.caption)
              .foregroundColor(.base500)
              .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
              LazyHStack(spacing: 8) {
                ForEach(viewModel.courseHoles[index * 9..<(index + 1) * 9]) {
                  hole in
                  HoleCard(
                    hole: hole,
                    mapType: mapType
                  ).environmentObject(viewModel)
                }
              }
              .padding(.horizontal)
            }
          }
        }
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 8) {
            ForEach(viewModel.courseHoles) { hole in
              HoleCard(
                hole: hole,
                mapType: mapType
              ).environmentObject(viewModel)
            }
          }
          .padding(.horizontal)
        }
      }
    }
    Spacer().frame(height: 200)
  }
}

#Preview {
  HoleCardList(mapType: .standard).environmentObject(CoursesViewModel())
}
