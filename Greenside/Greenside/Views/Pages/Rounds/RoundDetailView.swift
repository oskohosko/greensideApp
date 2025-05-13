//
//  RoundDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 6/5/2025.
//

import FirebaseCore
import SwiftUI

struct RoundDetailView: View {

  let round: Round
  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  @EnvironmentObject private var coursesViewModel: CoursesViewModel
  @State private var mapType: MapType = .standard

  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      VStack(alignment: .leading) {
        // Round Title
        HStack {
          VStack(alignment: .leading) {
            Text(round.title ?? "Golf Round")
              .font(.system(size: 32, weight: .bold))
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(.content)

            HStack(spacing: 4) {
              Image(systemName: "mappin.circle")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.accentGreen)
              Text(round.courseName ?? "Rosebud")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.content)
            }

          }
          Divider()
            .overlay(
              Rectangle()
                .frame(width: 3)
                .foregroundColor(Color.base400)
                .cornerRadius(10)
            )
          Text("\(round.score ?? 72)")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(.content)
            .padding()
        }
        .padding(.leading, 16)
        .padding(.bottom, 8)
        .frame(height: 120)

        ScrollView {
          VStack(spacing: 0) {
            ScoreTable(round: round)
              .padding(.horizontal)
              .padding(.bottom, 12)

            Text("Holes")
              .font(.system(size: 24, weight: .bold))
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(.content)
              .padding(.leading, 16)

            // MARK: UPDATE THIS SO WE CAN USE ANNOTATIONS
            HoleCardList(
              round: round,
              mapType: mapType
            )
            .environmentObject(coursesViewModel)
            .environmentObject(roundsViewModel)
          }

        }
      }
    }
    .onAppear {
      // Updating the current round
      roundsViewModel.currentRound = round
      Task {
        do {
          // Fetching hole data for the course of the round
          if let courseId = round.courseId {
            await roundsViewModel.loadCourseHoles(for: courseId)
            await coursesViewModel.loadHoles(for: courseId)
          } else {
            return
          }
          // Fetching hole data from the round
          await roundsViewModel.loadRoundHoles(for: round)
        }
      }
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

  RoundDetailView(round: testRound)
    .environmentObject(RoundsViewModel())
    .environmentObject(CoursesViewModel())
}
