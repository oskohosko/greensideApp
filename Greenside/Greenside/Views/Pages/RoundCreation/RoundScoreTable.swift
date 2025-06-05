//
//  RoundScoreTable.swift
//  Greenside
//
//  Created by Oskar Hosken on 5/6/2025.
//

import SwiftUI

struct RoundScoreTable: View {
  @EnvironmentObject private var vm: RoundCreationVM
//  @State private var editingScores: [Int: Int] = [:]
  @State private var showingFinalScoreEditor = false
//  @State private var customFinalScore: String = ""

  private var totalShots: Int {
    vm.roundShots.values.reduce(0) { $0 + $1.count }
  }

  private var totalPar: Int {
    vm.allHoles.reduce(0) { $0 + $1.par }
  }

  private var totalScore: Int {
    vm.allHoles.reduce(0) { sum, hole in
      let holeScore =
      vm.scores[hole.num] ?? vm.roundShots[hole.num]?.count ?? 0
      return sum + holeScore
    }
  }

  private var finalScore: Int {
    if let customScore = Int(vm.finalScore), !vm.finalScore.isEmpty {
      return customScore
    }
    return totalScore
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header
      HStack {
        Text("Round Summary")
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(.content)
        Spacer()
        Button {
          showingFinalScoreEditor.toggle()
        } label: {
          Image(systemName: "pencil.circle")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.accentGreen)
        }
      }
      .padding(.horizontal)

      // Table
      VStack(spacing: 0) {
        // Table Header
        HStack {
          Text("Hole")
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 50, alignment: .center)

          Text("Par")
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 50, alignment: .center)

          Text("Shots")
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 60, alignment: .center)

          Text("Score")
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 60, alignment: .center)

          Text("Diff")
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 50, alignment: .center)

          Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(.base300)
        .foregroundStyle(.content)

        // Table Rows
        ForEach(vm.allHoles.sorted(by: { $0.num < $1.num }), id: \.num) {
          hole in
          HoleScoreRow(
            hole: hole,
            shots: vm.roundShots[hole.num]?.count ?? 0
          )
          .environmentObject(vm)
        }

        // Total Row
        HStack {
          Text("Total")
            .font(.system(size: 16, weight: .bold))
            .frame(width: 50, alignment: .center)

          Text("\(totalPar)")
            .font(.system(size: 16, weight: .bold))
            .frame(width: 50, alignment: .center)

          Text("\(totalShots)")
            .font(.system(size: 16, weight: .bold))
            .frame(width: 60, alignment: .center)

          Text("\(finalScore)")
            .font(.system(size: 16, weight: .bold))
            .frame(width: 60, alignment: .center)

          let diff = finalScore - totalPar
          Text(diff > 0 ? "+\(diff)" : "\(diff)")
            .font(.system(size: 16, weight: .bold))
            .frame(width: 50, alignment: .center)
            .foregroundStyle(
              diff == 0 ? .content : (diff > 0 ? .lightRed : .accentGreen)
            )

          Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(.base300)
        .foregroundStyle(.content)
      }
      .background(.base100)
      .cornerRadius(12)
      .padding(.horizontal)
    }
    .sheet(isPresented: $showingFinalScoreEditor) {
      FinalScoreEditor(
        currentScore: finalScore
      )
      .environmentObject(vm)
      .presentationDetents([.height(300)])
    }
  }
}

// Individual hole row
private struct HoleScoreRow: View {
  let hole: Hole
  let shots: Int
//  @Binding var customScore: Int?
  @State private var showingScoreEditor = false
  
  @EnvironmentObject private var vm: RoundCreationVM

  private var displayScore: Int {
    vm.scores[hole.num] ?? shots
  }

  private var scoreDiff: Int {
    displayScore - hole.par
  }

  var body: some View {
    HStack {
      Text("\(hole.num)")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(.content)
        .frame(width: 50, alignment: .center)

      Text("\(hole.par)")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(.content)
        .frame(width: 50, alignment: .center)

      Text("\(shots)")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(shots == 0 ? .base400 : .content)
        .frame(width: 60, alignment: .center)
        

      Button {
        showingScoreEditor = true
      } label: {
        HStack(spacing: 4) {
          Text("\(displayScore)")
            .font(.system(size: 16, weight: .medium))
          if vm.scores[hole.num] != nil {
            Image(systemName: "pencil.circle.fill")
              .font(.system(size: 12))
              .foregroundStyle(.accentGreen)
          }
        }
      }
      .foregroundStyle(.content)
      .frame(width: 60, alignment: .center)

      let diff = scoreDiff
      Text(diff == 0 ? "E" : (diff > 0 ? "+\(diff)" : "\(diff)"))
        .font(.system(size: 16, weight: .medium))
        .frame(width: 50, alignment: .center)
        .foregroundStyle(
          diff == 0 ? .content : (diff > 0 ? .lightRed : .accentGreen)
        )

      Spacer()
    }
    .padding(.vertical, 8)
    .padding(.horizontal)
    .background(hole.num % 2 == 0 ? .base100 : .base200)
    .sheet(isPresented: $showingScoreEditor) {
      HoleScoreEditor(
        hole: hole,
        currentShots: shots
      )
      .environmentObject(vm)
      .presentationDetents([.height(350)])
    }
  }
}

// Score editor for individual holes
private struct HoleScoreEditor: View {
  let hole: Hole
  let currentShots: Int
//  @Binding var customScore: Int?
  @Environment(\.dismiss) private var dismiss
  @State private var tempScore: String = ""
  
  @EnvironmentObject private var vm: RoundCreationVM

  var body: some View {
    NavigationStack {
      VStack(spacing: 8) {
        Text("Edit Score for Hole \(hole.num)")
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(.content)

        VStack(alignment: .leading, spacing: 8) {
          Text("Current shots recorded: \(currentShots)")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.base400)
        }

        VStack(alignment: .leading, spacing: 8) {
          Text("Score")
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(.content)

          TextField("Enter score", text: $tempScore)
            .foregroundStyle(.content)
            .keyboardType(.numberPad)
            .font(.system(size: 18))
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(.base100)
            .cornerRadius(8)
        }

        HStack(spacing: 16) {
          Button {
            vm.scores[hole.num] = currentShots
            dismiss()
          } label: {
            Text("Use Shots (\(currentShots))")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.content)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(.base300)
              .cornerRadius(8)
          }

          Button {
            if let score = Int(tempScore), score > 0 {
              vm.scores[hole.num] = score
              dismiss()
            }
          } label: {
            Text("Save Score")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.white)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(.accentGreen)
              .cornerRadius(8)
          }
          .disabled(
            tempScore.isEmpty || Int(tempScore) == nil || Int(tempScore)! <= 0
          )
        }

        Spacer()
      }
      .padding()
      .background(.base200)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
          .foregroundStyle(.content)
        }
      }
    }
    .onAppear {
      if let score = vm.scores[hole.num] {
        tempScore = "\(score)"
      } else {
        tempScore = "\(currentShots)"
      }
    }
  }
}

// Final score editor
private struct FinalScoreEditor: View {
  let currentScore: Int
//  @Binding var customScore: String
  @Environment(\.dismiss) private var dismiss
  @State private var tempScore: String = ""
  
  @EnvironmentObject private var vm: RoundCreationVM

  var body: some View {
    NavigationStack {
      VStack(spacing: 8) {
        Text("Edit Total Score")
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(.content)

        Text("Current score: \(currentScore)")
          .font(.system(size: 18, weight: .medium))
          .foregroundStyle(.base400)

        VStack(alignment: .leading, spacing: 8) {
          Text("Final Score")
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(.content)

          TextField("Enter final score", text: $tempScore)
            .keyboardType(.numberPad)
            .font(.system(size: 18))
            .foregroundStyle(.content)
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(.base100)
            .cornerRadius(8)
            
        }

        HStack(spacing: 16) {
          Button {
            vm.finalScore = "\(currentScore)"
            dismiss()
          } label: {
            Text("Use Calculated (\(currentScore))")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.content)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(.base300)
              .cornerRadius(8)
          }

          Button {
            if Int(tempScore) != nil, !tempScore.isEmpty {
              vm.finalScore = tempScore
              dismiss()
            }
          } label: {
            Text("Save Score")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.white)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(.accentGreen)
              .cornerRadius(8)
          }
          .disabled(
            tempScore.isEmpty || Int(tempScore) == nil || Int(tempScore)! <= 0
          )
        }

        Spacer()
      }
      .padding()
      .background(.base200)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
          .foregroundStyle(.content)
        }
      }
    }
    .onAppear {
      tempScore = vm.finalScore.isEmpty ? "\(currentScore)" : vm.finalScore
    }
  }
}

#Preview {
  RoundScoreTable().environmentObject(RoundCreationVM())
}
