//
//  FirebaseManager.swift
//  Greenside
//
//  Created by Oskar Hosken on 6/5/2025.
//

import CoreLocation
import FirebaseFirestore
import Foundation

// Data models

// A shot that belongs to a hole in a round
struct Shot: Identifiable, Codable, Equatable {
  @DocumentID var id: String?
  var distanceToPin: Int?
  var time: Double?
  var userLat: Double?
  var userLong: Double?
}

extension Shot {
  var location: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: userLat!, longitude: userLong!)
  }
}

// A hole that belongs to a round
struct RoundHole: Identifiable, Codable, Equatable {
  @DocumentID var id: String?
  var greenLat: Double?
  var greenLong: Double?
  var holeNum: Int?
  var score: Int?
}

// Round of golf struct
struct Round: Identifiable, Codable {
  @DocumentID var id: String?
  var courseId: Int?
  var courseName: String?
  var createdAt: Timestamp?
  var score: Int?
  var title: String?
}
// Changes the createdAt to the format "Mar 21" for example
extension Round {
  var shortDate: String? {
    guard let timestamp = createdAt else {
      return "Invalid Date"
    }
    let date = timestamp.dateValue()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd"
    return dateFormatter.string(from: date)
  }
}

final class FirebaseManager {
  static let shared = FirebaseManager()
  private init() {}

  // Our database
  private let db = Firestore.firestore()

  // This fetches every round in our rounds collection
  func getAllRounds() async throws -> [Round] {
    let snapshot = try await db.collection("rounds").getDocuments()
    return snapshot.documents.compactMap { try? $0.data(as: Round.self) }
  }

  // Getting a round by its ID
  func getRound(byId roundId: String) async throws -> Round {
    let doc = try await db.collection("rounds").document(roundId).getDocument()
    guard let round = try doc.data(as: Round?.self) else {
      throw NSError(
        domain: "FirebaseManager",
        code: 404,
        userInfo: [NSLocalizedDescriptionKey: "Round not found"]
      )
    }
    return round
  }

  // Getting holes for a round
  func getHoles(forRound roundId: String) async throws -> [RoundHole] {
    let snapshot = try await db.collection("rounds").document(roundId)
      .collection("holes").order(by: "holeNum").getDocuments()
    return snapshot.documents.compactMap { try? $0.data(as: RoundHole.self) }
  }

  // Getting a hole by its id
  func getHole(roundId: String, holeId: String) async throws -> RoundHole {
    let doc = try await db.collection("rounds").document(roundId).collection(
      "holes"
    ).document(holeId).getDocument()
    guard let hole = try doc.data(as: RoundHole?.self) else {
      throw NSError(
        domain: "FirebaseManager",
        code: 404,
        userInfo: [NSLocalizedDescriptionKey: "Hole not found"]
      )
    }
    return hole
  }

  // Getting shots on a hole
  func getShots(roundId: String, holeId: String) async throws -> [Shot] {
    let snapshot = try await db.collection("rounds")
      .document(roundId)
      .collection("holes")
      .document(holeId)
      .collection("shots")
      .order(by: "time")
      .getDocuments()

    return snapshot.documents.compactMap { try? $0.data(as: Shot.self) }
  }

  // MARK: - Methods for SAVING a round to firebase.
  func saveRound(
    title: String,
    courseName: String,
    courseId: Int,
    roundDate: Date,
    holes: [Hole],
    roundShots: [Int: [Shot]],
    scores: [Int: Int] = [:],
    finalScore: Int
  ) async throws {

    // Create the round document
    let roundData: [String: Any] = [
      "title": title,
      "courseName": courseName,
      "courseId": courseId,
      "createdAt": roundDate,
      "score": finalScore,
    ]

    let roundRef = try await db.collection("rounds").addDocument(
      data: roundData
    )
    print("Round created with ID: \(roundRef.documentID)")

    // Save each hole and its shots
    for hole in holes {
      try await saveHoleToRound(
        roundRef: roundRef,
        hole: hole,
        shots: roundShots[hole.num] ?? [],
        score: scores[hole.num]
      )
    }

    print("Round saved successfully!")
  }

  private func saveHoleToRound(
    roundRef: DocumentReference,
    hole: Hole,
    shots: [Shot],
    score: Int?
  ) async throws {

    // Determine the score for this hole
    let holeScore = score ?? shots.count

    let holeData: [String: Any] = [
      "holeNum": hole.num,
      "greenLat": hole.greenLocation.latitude,
      "greenLong": hole.greenLocation.longitude,
      "score": holeScore,
    ]

    let holeRef = try await roundRef.collection("holes").addDocument(
      data: holeData
    )
    print("Hole \(hole.num) created with score: \(holeScore)")

    // Save all shots for this hole
    for shot in shots {
      try await saveShotToHole(holeRef: holeRef, shot: shot)
    }
  }

  private func saveShotToHole(holeRef: DocumentReference, shot: Shot)
    async throws
  {
    let shotData: [String: Any] = [
      "distanceToPin": shot.distanceToPin,
      "time": shot.time,
      "userLat": shot.userLat,
      "userLong": shot.userLong,
    ]

    let _ = try await holeRef.collection("shots").addDocument(data: shotData)
  }
}
