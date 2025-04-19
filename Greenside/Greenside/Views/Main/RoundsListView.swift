//
//  RoundsListView.swift
//  Greenside
//
//  Created by Oskar Hosken on 18/4/2025.
//

import SwiftUI

struct RoundsListView: View {
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 16) {
        ForEach(0..<10) { _ in
          RoundCardView()
        }
      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  RoundsListView()
}
