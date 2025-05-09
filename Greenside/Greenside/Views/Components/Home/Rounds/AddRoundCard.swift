//
//  AddRoundCard.swift
//  Greenside
//
//  Created by Oskar Hosken on 8/5/2025.
//

import SwiftUI

struct AddRoundCard: View {
  var body: some View {
    NavigationLink {
      AddRoundView()
    } label: {
      VStack {
        Text("Add Round")
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(.content)
        Image(systemName: "plus.circle")
          .font(.system(size: 42, weight: .medium))
          .foregroundStyle(.accentGreen)
        Spacer()

      }
      .padding()
      .frame(width: 120, height: 110)
      .fixedSize(horizontal: false, vertical: true)
      .background(Color.base100)
      .cornerRadius(20)
      .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
  }
}

#Preview {
  AddRoundCard()
}
