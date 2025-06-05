//
//  BadgeView.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import SwiftUI

struct Badge: View {

  var text: String = ""
  var colour: Color = .secondary
  var image: String?
  var size: CGFloat = 16

  var body: some View {
    HStack(spacing: 6) {
      if let image = image {
        Image(systemName: image)
          .font(.system(size: size, weight: .medium))
          .foregroundStyle(.content)
        Text(text)
          .foregroundStyle(.content)
          .font(.system(size: (size + 2), weight: .medium))
      } else {
        Text(text)
          .foregroundStyle(.content)
          .font(.system(size: (size + 2), weight: .medium))
      }
    }
    .padding(size / 3)
    .padding(.horizontal, 8)
    .background(colour)
    .opacity(0.8)
    .cornerRadius(16)

  }
}

#Preview {
  Badge(
    text: "Play again?",
    colour: Color((.secondary))
  )
}
