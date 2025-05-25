//
//  RoundsViewModel.swift
//  Greenside
//
//  Created by Oskar Hosken on 6/5/2025.
//
import Foundation

@MainActor
class RoundsViewModel: ObservableObject {
  
  // Public state
  @Published var allRounds: [Round] = []
  @Published var currentRound: Round?
  @Published var roundHoles: [RoundHole] = []
  @Published var currentHole: RoundHole?
  @Published var courseHoles: [Hole] = []
  @Published var roundShots: [Int: [Shot]] = [:]
  @Published var selectedShot: Shot?
  
  // Private caches
  private var holesCache: [String: [RoundHole]] = [:]
  private var shotsCache: [String: [Int: [Shot]]] = [:]
  
  // using our course repository to fetch course data for us
  private let courseRepo = CourseRepository.shared
  private let firebase = FirebaseManager.shared

  // Loads rounds from our Firebase
  func loadRounds() async {
    // Don't want to load the rounds every time we go to the home page
    guard allRounds.isEmpty else {
      return
    }
    do {
      allRounds = try await firebase.getAllRounds()
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
    
    // Firstly serving from the cache if we have fetched these holes
    if let cachedHoles = holesCache[roundId] {
      roundHoles = cachedHoles
      return
    }
    
    // Otherwise fetching from Firebase and caching
    do {
      let holes = try await firebase.getHoles(forRound: roundId)
      roundHoles = holes
      holesCache[roundId] = holes
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
    // Firstly checking the hole cache
    if let cachedShots = shotsCache[roundId]?[holeNum] {
      return cachedShots
    }
    // Otherwise fetching from Firebase
    guard let holeId = hole.id else {
      return []
    }
    do {
      let shots = try await firebase.getShots(
        roundId: roundId, holeId: holeId)
      
      // Updating the view and cache
      await MainActor.run {
        roundShots[holeNum] = shots
        if shotsCache[roundId] == nil {
          shotsCache[roundId] = [:]
        }
        shotsCache[roundId]![holeNum] = shots
      }
      return shots
    } catch {
      print("Error loading shots for hole \(holeNum): \(error)")
      return []
    }
  }
  
  // Loads all shots made in the round
  func loadRoundShots() async -> [Int: [Shot]]{
    guard let round = currentRound, let roundId = round.id else {
      return [:]
    }
    // Checking if we have already loaded these shots
    if let cachedShots = shotsCache[roundId] {
      roundShots = cachedShots
      return cachedShots
    }
    
    // Otherwise loading the holes and shots
    
    // Loading holes first
    guard !roundHoles.isEmpty else {
      return [:]
    }
    
    // And now fetching each set of shots in parallel
    var tempShots: [Int: [Shot]] = [:]
    
    await withTaskGroup(of: (Int, [Shot]).self) { group in
      for (index, hole) in roundHoles.enumerated() {
        let holeNum = index + 1
        // Adding a new task for each hole
        group.addTask {
          let shots = await self.loadHoleShots(
            roundId: roundId, hole: hole, holeNum: holeNum)
          return (holeNum, shots)
        }
      }
      // Yields each child's result in completion order
      for await (holeNum, shots) in group {
        tempShots[holeNum] = shots
      }
    }
    
    // Updating our cache
    roundShots = tempShots
    shotsCache[roundId] = tempShots
    return tempShots
  }
  
  func previousHole(current: Int) -> Hole? {
    guard let idx = courseHoles.firstIndex(where: { $0.num == current }),
      idx > 0
    else { return nil }
    return courseHoles[idx - 1]
  }

  func nextHole(current: Int) -> Hole? {
    guard let idx = courseHoles.firstIndex(where: { $0.num == current }),
      idx < courseHoles.count - 1
    else { return nil }
    return courseHoles[idx + 1]
  }
  
}
