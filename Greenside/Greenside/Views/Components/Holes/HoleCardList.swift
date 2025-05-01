//
//  HoleCardList.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import SwiftUI

struct HoleCardList: View {
  @EnvironmentObject private var viewModel: CoursesViewModel
  var body: some View {
    ScrollView(.horizontal) {
      LazyHStack(spacing: 8) {
        ForEach(viewModel.courseHoles) { hole in
          HoleCard(
            hole: hole
          ).environmentObject(viewModel)
        }
      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  HoleCardList().environmentObject(CoursesViewModel())
}
