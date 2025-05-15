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
  @Published var roundHoles: [RoundHole] = []
  @Published var currentHole: RoundHole?
  
  @Published var courseHoles: [Hole] = []
  
  @Published var roundShots: [Int: [Shot]] = [:]
  
  
  // using our course repository to fetch course data for us
  private let courseRepo = CourseRepository.shared

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
  
  // Loads all the holes played in the round
  func loadRoundHoles(for round: Round) async {
    guard let roundId = round.id else {
      print("Invalid round ID")
      return
    }
    do {
      roundHoles = try await FirebaseManager.shared.getHoles(forRound: roundId)
    } catch {
      print("Error loading holes for round: \(roundId), \(error)")
    }
  }
  
  // Loads holes for a course.
  // Helps with map stuff and score stuff
  func loadCourseHoles(for courseId: Int) async {
    do {
      let courseData = try await courseRepo.loadHoles(for: courseId)
      courseHoles = courseData.holes
    } catch {
      print("Holes loading failed:", error)
    }
  }
  // Loads the shots made on a hole in a round
  func loadHoleShots(roundId: String, hole: RoundHole, holeNum: Int) async -> [Shot] {
    do {
      if let holeId = hole.id {
        let shots = try await FirebaseManager.shared.getShots(roundId: roundId, holeId: holeId)
        // Updating our cache of shots in a round
        roundShots[holeNum] = shots
        return shots
      } else {
        return []
      }
    } catch {
      print("Error loading shots for round \(roundId) and hole \(hole): \(error)")
    }
    return []
  }
  
  // Loads all shots made in the round
  func loadRoundShots() async -> [Int: [Shot]]{
    guard let round = currentRound else {
      print("No current round")
      return [:]
    }
    do {
      if roundHoles.isEmpty {
        return [:]
      }
      for (index, hole) in roundHoles.enumerated() {
        _ = await self.loadHoleShots(roundId: round.id!, hole: hole, holeNum: index + 1)
          
      }
      return roundShots
    }
    
  }
  
}
