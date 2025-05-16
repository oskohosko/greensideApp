//
//  RoundHoleListSkeleton.swift
//  Greenside
//
//  Created by Oskar Hosken on 16/5/2025.
//

import SwiftUI

struct RoundHoleListSkeleton: View {
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      ForEach(0..<2) { index in
        VStack(alignment: .leading, spacing: 4) {
          Text(index == 0 ? "Front Nine" : "Back Nine")
            .font(.caption)
            .foregroundColor(.base500)
            .padding(.horizontal)
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

              ForEach(0..<4) { index in
                RoundHoleCardSkeleton()
              }
            }
            .padding(.horizontal)
          }
        }
      }
    }
    Spacer().frame(height: 200)
  }
}

#Preview {
  RoundHoleListSkeleton()
}
