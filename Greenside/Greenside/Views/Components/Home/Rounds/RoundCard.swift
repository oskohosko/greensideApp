//
//  RoundCardView.swift
//  Greenside
//
//  Created by Oskar Hosken on 18/4/2025.
//

import FirebaseCore
import SwiftUI

struct RoundCard: View {
  
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility
  @EnvironmentObject private var router: Router

  // The round we are displaying
  let round: Round

  @State private var isDragging = false

  var body: some View {
    Button {
      router.navigateToRound(round)
    } label: {
      HStack {
        VStack {
          Text(round.title ?? "")
            .font(.headline)
            .foregroundColor(.content)
            .frame(maxWidth: .infinity, alignment: .leading)
          Spacer()
          HStack(spacing: 6) {
            Image(systemName: "clock")
              .foregroundColor(.accentGreen)
              .fontWeight(.bold)
              .font(.subheadline)
            Text(round.shortDate ?? "")
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
        Text("\(round.score ?? 72)")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(.content)
          .padding(.leading, 10)

      }.padding()
        .frame(width: 200, height: 110)
        .fixedSize(horizontal: false, vertical: true)
        .background(isDragging ? Color.base101 : Color.base100)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .simultaneousGesture(
          DragGesture()
            .onChanged { _ in
              isDragging = true
            }
            .onEnded { _ in
              isDragging = false
            }
        )
    }
  }

}

#Preview {
  let testRound = Round(
    courseId: 1017,
    courseName: "Rosebud Country Club South",
    createdAt: Timestamp(date: Date(timeIntervalSince1970: 1_731_227_571)),
    score: 77,
    title: "Rosebud South Tuesday"
  )

  RoundCard(round: testRound)
    .environmentObject(TabBarVisibility())
    .environmentObject(Router())
}
