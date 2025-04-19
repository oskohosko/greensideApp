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

struct RoundCardView: View {
  var body: some View {
    HStack {
      VStack {
        Text(sampleRound["name"] as? String ?? "")
          .font(.headline)
          .lineLimit(3)
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
      .frame(width: 200, height: 100)
      .background(Color.base100)
      .cornerRadius(20)
  }
}

#Preview {
  RoundCardView()
}
