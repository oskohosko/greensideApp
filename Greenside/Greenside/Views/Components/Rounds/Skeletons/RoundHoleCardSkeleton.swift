//
//  RoundHoleCardSkeleton.swift
//  Greenside
//
//  Created by Oskar Hosken on 16/5/2025.
//

import SwiftUI

struct RoundHoleCardSkeleton: View {
  
  private let placeholder = Color.base300
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      // “Hole x” line
      RoundedRectangle(cornerRadius: 4)
        .fill(placeholder)
        .frame(width: 48, height: 14)
        .padding(.top, 4)

      // Par / distance line
      HStack {
        RoundedRectangle(cornerRadius: 3)
          .fill(placeholder)
          .frame(width: 36, height: 10)
        Spacer(minLength: 0)
        RoundedRectangle(cornerRadius: 3)
          .fill(placeholder)
          .frame(width: 46, height: 10)
      }
      .padding(.bottom, 4)

      // Map skeleton
      RoundedRectangle(cornerRadius: 12)
        .fill(placeholder)
        .frame(height: 120)
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 4)
    .frame(width: 120, height: 180)
    .background(Color.base100)
    .cornerRadius(15)
    // Shimmer
    .redacted(reason: .placeholder)
  }
}

#Preview {
  RoundHoleCardSkeleton()
}
