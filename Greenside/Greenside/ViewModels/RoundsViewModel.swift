//
//  RoundsViewModel.swift
//  Greenside
//
//  Created by Oskar Hosken on 6/5/2025.
//
import Foundation
import SwiftUI

struct Flair: Identifiable {
  var id: UUID = UUID()
  var label: String
  var colour: Color
}

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

  // Public state for the badges for the current hole/shots
  @Published var holeShotBadges: [[Flair]] = []
  @Published var holeBadges: [Flair] = []
  @Published var isLoading: Bool = false

  // Private caches
  private var holesCache: [String: [RoundHole]] = [:]
  private var shotsCache: [String: [Int: [Shot]]] = [:]

  // using our course repository to fetch course data for us
  private let courseRepo = CourseRepository.shared
  private let firebase = FirebaseManager.shared

  // Map manager for distance and geometry calcs
  private let mapManager = MapManager()

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
  func loadHoleShots(roundId: String, hole: RoundHole, holeNum: Int) async
    -> [Shot]
  {
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
        roundId: roundId,
        holeId: holeId
      )

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
  func loadRoundShots() async -> [Int: [Shot]] {
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
            roundId: roundId,
            hole: hole,
            holeNum: holeNum
          )

          return (holeNum, shots)
        }
      }
      // Yields each child's result in completion order
      for await (holeNum, shots) in group {
        tempShots[holeNum] = shots
      }
    }

    // Updating our cache
    self.roundShots = tempShots
    self.shotsCache[roundId] = tempShots
    return tempShots
  }

  // This function generates some badges for the hole based on the shots
  func generateHoleBadges(
    shots: [Shot],
    hole: Hole,
    score: Int
  ) -> [Flair] {
    
    self.clearBadges()
    
    let allShotBadges = generateShotBadges(
      shots: shots,
      hole: hole,
      score: score
    )
    
    var holeBadges: [Flair] = []

    // Getting the badge for the score
    let relToPar = score - hole.par
    switch relToPar {
    case ..<(-2):
      holeBadges.append(Flair(label: "🎉 Albatross", colour: .yellow200))
    case -2:
      holeBadges.append(Flair(label: "🦅 Eagle", colour: .yellow200))
    case -1:
      holeBadges.append(Flair(label: "🐦 Birdie", colour: .red200))
    case 0:
      holeBadges.append(Flair(label: "👍 Par", colour: .green200))
    case 1:
      holeBadges.append(Flair(label: "☹️ Bogey", colour: .blue200))
    case 2:
      holeBadges.append(Flair(label: "😫 Double bogey", colour: .blue200))
    default:
      holeBadges.append(Flair(label: "😭 \(relToPar)-over", colour: .brown200))
    }

    let shotBadgeLabels = Set(allShotBadges.flatMap { $0.map { $0.label } })

    // Checking existing labels
    if shotBadgeLabels.contains("🏆 Long drive") {
      holeBadges.append(Flair(label: "🏆 Long drive", colour: .yellow200))
    }

    if shotBadgeLabels.contains("🎯 Solid shot") {
      holeBadges.append(Flair(label: "🎯 Close approach!", colour: .green200))
    }

    if shotBadgeLabels.contains("💣 Dropped a bomb!") {
      holeBadges.append(Flair(label: "💣 Dropped a bomb!", colour: .orange200))
    }

    if shotBadgeLabels.contains("📦 Packed it in") {
      holeBadges.append(Flair(label: "📦 Packed it in", colour: .brown200))
    }

    // And now checking extra things

    // Up and down
    if shots.count >= 2 {
      let last = shots[shots.count - 1]
      let prev = shots[shots.count - 2]
      let isPutt = { (shot: Shot) in (shot.distanceToPin ?? 11) <= 10 }

      if isPutt(last) && !isPutt(prev) {
        holeBadges.append(Flair(label: "⛳ Up & down!", colour: .blue200))
      }
    }
    // 3-putt
    if shots.count >= 3 {
      let lastThree = shots.suffix(3)
      let puttCount = lastThree.filter { ($0.distanceToPin ?? 11) <= 10 }.count
      if puttCount == 3 {
        holeBadges.append(Flair(label: "💩 3-putt", colour: .brown200))
      }
    }

    self.holeBadges = holeBadges
    return holeBadges
  }

  // This function generates some badges for the individual shot
  func generateShotBadges(shots: [Shot], hole: Hole, score: Int) -> [[Flair]] {
    var allShotBadges: [[Flair]] = []
    // Going through each shot and calculating shotBadges
    for (index, shot) in shots.enumerated() {
      var shotBadges: [Flair] = []
      // Checking if there is a previous or next shot
      let isPrev = index > 0
      let isNext = index < shots.count - 1
      // Distance of last shot
      let distanceFromPrevious =
        isPrev
        ? mapManager.distanceBetweenPoints(
          from: shots[index - 1].location,
          to: shot.location
        ) : nil

      // Distance of current shot
      let distanceOfCurrent =
        isNext
        ? mapManager.distanceBetweenPoints(
          from: shot.location,
          to: shots[index + 1].location
        )
        : mapManager.distanceBetweenPoints(
          from: shot.location,
          to: hole.greenLocation
        )
      // Now getting categories of the shot
      let isTeeShot = index == 0
      let distanceToPin = shot.distanceToPin ?? 0
      let shotType =
        isTeeShot
        ? "🏌️ Tee Shot"
        : distanceToPin > 100
          ? "🎯 Approach"
          : distanceToPin > 30
            ? "🪁 Pitch"
            : distanceToPin > 10
              ? "⛳ Chip"
              : "🥅 Putt"
      // Adding shot type as a badge
      shotBadges.append(Flair(label: shotType, colour: .accentGreen))

      let nextShot = isNext ? shots[index + 1] : nil

      // And now adding shotBadges for the shot
      if nextShot != nil {
        // Long drive
        if (Int(distanceOfCurrent) > 250) && shotType == "🏌️ Tee Shot" {
          shotBadges.append(
            Flair(label: "🏆 Long drive", colour: .yellow200)
          )
        }
        // Big shot flair
        if (Int(distanceOfCurrent) > 200) && shotBadges.last?.label != "🏆 Long drive" {
          shotBadges.append(
            Flair(label: "⚡ Big move", colour: .yellow200)
          )
        }
        // Hitting a close shot
        if Int(distanceOfCurrent) > 50
          && nextShot!.distanceToPin! < Int(distanceOfCurrent) / 10
        {
          shotBadges.append(
            Flair(label: "🎯 Solid shot", colour: .green200)
          )
        }
        // Short shot
        if Int(distanceOfCurrent) < 30 {
          shotBadges.append(
            Flair(label: "🪶 Touch shot", colour: .blue200)
          )
        }
        // Bad shot
        if ((Int(distanceOfCurrent) < nextShot!.distanceToPin!)
          || (nextShot!.distanceToPin! > shot.distanceToPin! / 2))
          && !(hole.par == 5)
        {
          shotBadges.append(
            Flair(label: "💥 Mishit", colour: .red200)
          )
        }
      } else {
        // Pick up - if no next shot and it doesn't equal the score on the hole
        if (index + 1) != score {
          shotBadges.append(
            Flair(label: "📦 Packed it in", colour: .brown200)
          )
        }
        // Hole out or big putt
        else if shot.distanceToPin! > 10 {
          shotBadges.append(
            Flair(label: "💣 Dropped a bomb!", colour: .orange200)
          )
        }
      }
      // Adding this shot's badges to all badges
      allShotBadges.append(shotBadges)
    }
    self.holeShotBadges = allShotBadges
    return allShotBadges
  }
  
  func clearBadges() {
    self.holeShotBadges = []
    self.holeBadges = []
  }

  // Function that returns the previous hole if it exists
  func previousHole(current: Int) -> Hole? {
    guard let idx = courseHoles.firstIndex(where: { $0.num == current }),
      idx > 0
    else { return nil }
    return courseHoles[idx - 1]
  }

  // Returns the next hole if it exists
  func nextHole(current: Int) -> Hole? {
    guard let idx = courseHoles.firstIndex(where: { $0.num == current }),
      idx < courseHoles.count - 1
    else { return nil }
    return courseHoles[idx + 1]
  }

}
