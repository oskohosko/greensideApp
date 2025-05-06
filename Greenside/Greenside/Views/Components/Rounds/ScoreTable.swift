//
//  ScoreTable.swift
//  Greenside
//
//  Created by Oskar Hosken on 6/5/2025.
//

import FirebaseCore
import SwiftUI

struct ScoreTable: View {

  let round: Round

  @EnvironmentObject private var roundsViewModel: RoundsViewModel

  // List of scores
  var scores: [Int] {
    // Mapping each hole in the round to its score
    return roundsViewModel.roundHoles.map { $0.score ?? 0 }
  }
  // List of pars
  var pars: [Int] {
    // Mapping each hole to its par
    return roundsViewModel.courseHoles.map { $0.par }
  }

  //  let scores: [Int]
  //  let pars: [Int]

  var body: some View {
    VStack(spacing: 0) {
      TableRow(
        scores: Array(scores.prefix(9)),
        pars: Array(pars.prefix(9))
      )
      Divider()
        .overlay(
          Rectangle()
            .frame(height: 2)
            .foregroundColor(Color.base200)
            .cornerRadius(10)
        )
      TableRow(
        scores: Array(scores.suffix(9)),
        pars: Array(pars.suffix(9))
      )
    }
    .padding(2)
    .background(.base100)
    .cornerRadius(8)
    .fixedSize(horizontal: true, vertical: false)
    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

// A row in our score table
private struct TableRow: View {
  
  let scores: [Int]
  let pars: [Int]

  var total: Int {
    // Summing up every score
    scores.reduce(0, +)
  }

  var body: some View {
    HStack(spacing: 0) {
      ForEach(scores.indices, id: \.self) { idx in
        ScoreCell(score: scores[idx], par: pars[idx])
        if idx != scores.indices.last {
          Divider()
            .overlay(
              Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.base200)
                .cornerRadius(10)
            )
        } else {
          Divider()
            .overlay(
              Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.base200)
                .cornerRadius(10)
            )
          ScoreCell(score: total, par: total)

        }
      }
      .padding(3)
    }
    .fixedSize()
  }
}

// And a cell in our score table
private struct ScoreCell: View {
  let score: Int
  let par: Int

  private var diff: Int { score - par }

  var body: some View {
    Text("\(score)")
      .font(.subheadline)
      .frame(width: 25, height: 25)
      .background(Color.base100)
      .overlay(outline)
      .foregroundStyle(.content)
  }

  // Outline view chosen by diff
  @ViewBuilder private var outline: some View {
    switch diff {
    case ..<(-1): doubleCircle
    case -1: singleCircle
    case 0: EmptyView()  // par – no outline
    case 1: singleRounded
    default: doubleRounded
    }
  }

  // MARK: - Colour helpers
  private var outlineColour: Color {
    switch diff {
    case ..<(-1): return .accentGreen  // eagle or better
    case -1: return .lightRed  // birdie
    case 0: return .base100  // not used
    default: return .lightBlue  // bogey or worse
    }
  }

  // MARK: - Shapes
  private var singleCircle: some View {
    Circle().stroke(outlineColour, lineWidth: 2)
  }

  private var doubleCircle: some View {
    Circle().stroke(outlineColour, lineWidth: 2)
      .overlay(Circle().inset(by: 3).stroke(outlineColour, lineWidth: 2))
  }

  private var singleRounded: some View {
    RoundedRectangle(cornerRadius: 6).stroke(outlineColour, lineWidth: 2)
  }

  private var doubleRounded: some View {
    RoundedRectangle(cornerRadius: 6).stroke(outlineColour, lineWidth: 2)
      .overlay(
        RoundedRectangle(cornerRadius: 6).inset(by: 3).stroke(
          outlineColour,
          lineWidth: 2
        )
      )
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

  let scores = [4, 6, 4, 3, 4, 3, 5, 5, 4, 4, 3, 5, 3, 5, 5, 4, 3, 4]

  let pars = [4, 4, 4, 3, 4, 4, 3, 4, 5, 4, 3, 4, 3, 4, 5, 5, 4, 4]

  ScoreTable(round: testRound)
    .environmentObject(RoundsViewModel())
}
