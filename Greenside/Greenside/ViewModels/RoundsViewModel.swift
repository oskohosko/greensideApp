//
//  RoundsViewModel.swift
//  Greenside
//
//  Created by Oskar Hosken on 6/5/2025.
//
import Foundation

@MainActor
class RoundsViewModel: ObservableObject {
  @Published var allRounds: [Round] = []
  @Published var currentRound: Round?

  // Loads rounds from our Firebase
  func loadRounds() async {
    // Don't want to load the rounds every time we go to the home page
    if !allRounds.isEmpty {
      return
    }
    do {
      allRounds = try await FirebaseManager.shared.getAllRounds()
    } catch {
      print("Error loading rounds: \(error)")
    }
  }
}
