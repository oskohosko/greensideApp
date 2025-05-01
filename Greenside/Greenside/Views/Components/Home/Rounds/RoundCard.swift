//
//  RoundCardView.swift
//  Greenside
//
//  Created by Oskar Hosken on 18/4/2025.
//

import SwiftUI

let sampleRound: [String: Any] = [
  "name": "Rosebud North Tuesday",
  "score": "77",
  "date": "Mar 21",
]

struct RoundCard: View {
  var body: some View {
    HStack {
      VStack {
        Text(sampleRound["name"] as? String ?? "")
          .font(.headline)
          .lineLimit(2)
          .foregroundColor(.content)
          .frame(maxWidth: .infinity, alignment: .leading)
        Spacer()
        HStack(spacing: 6) {
          Image(systemName: "clock")
            .foregroundColor(.accentGreen)
            .fontWeight(.bold)
            .font(.subheadline)
          Text(sampleRound["date"] as? String ?? "")
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.content)
        }
        
      }
      Divider()
        .frame(width: 1)
        .overlay(
          Rectangle()
            .frame(width: 3)
            .foregroundColor(Color.base200)
            .cornerRadius(10)
        )
      Text(sampleRound["score"] as? String ?? "")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(.content)
        .padding(.leading, 10)
      
        
    }.padding()
      .frame(width: 200, height: 110)
      .fixedSize(horizontal: false, vertical: true)
      .background(Color.base100)
      .cornerRadius(20)
      .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

#Preview {
  RoundCard()
}
