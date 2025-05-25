//
//  ShotsSheetView.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/5/2025.
//

import SwiftUI

struct Flair: Identifiable {
  var id: UUID = UUID()
  var label: String
  var colour: Color
}

struct ShotsSheetView: View {
  let shots: [Shot]
  let hole: Hole
  let score: Int

  @EnvironmentObject private var sheetPosition: SheetPositionHandler

  var body: some View {
    VStack(spacing: 0) {
      VStack {
        // Header HStack
        HStack {
          Spacer().frame(width: 30)
          Spacer()
          VStack(spacing: 0) {
            Capsule()
              .fill(.base300)
              .frame(width: 40, height: 6)
            Text("Shots")
              .font(.system(size: 28, weight: .bold))
              .foregroundStyle(.content)
              .padding(.top, 4)
          }
          Spacer()
          // Displaying a dismiss button if the sheet is in view
          if sheetPosition.position != .bottom {
            Button {
              withAnimation(.easeInOut(duration: 0.1)) {
                sheetPosition.position = .bottom
              }
            } label: {
              Image(systemName: "xmark")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.base300)
                .frame(width: 30)
            }

          } else {
            Spacer().frame(width: 30)
          }

        }
        .padding(.horizontal)
      }
      .padding(.top, 12)
      .frame(height: 80)
      .background(.base100)

      // Shots list goes here
      ShotsList(shots: shots, hole: hole, score: score)
        .environmentObject(sheetPosition)
    }
    .background(.base100)
    .cornerRadius(20)
    .frame(maxHeight: .infinity)

  }
}

// List of shots
struct ShotsList: View {
  let shots: [Shot]
  let hole: Hole
  let score: Int
  @EnvironmentObject private var sheetPosition: SheetPositionHandler
  private let mapManager = MapManager()

  // We want to map every shot to a shot card
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack(alignment: .leading, spacing: 0) {
        // Calculating data
        ForEach(Array(shots.enumerated()), id: \.offset) { index, shot in
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
          // And now adding flairs for the shot
          let flairs = getFlairs(
            currShot: shot,
            nextShot: isNext ? shots[index + 1] : nil,
            currDistance: Int(distanceOfCurrent),
            index: index
          )

          Text("Shot \(index + 1)")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.content)
            .padding(.bottom, 2)

          ShotsCard(
            shot: shot,
            distance: Int(distanceOfCurrent),
            shotType: shotType,
            flairs: flairs
          )
          .padding(.bottom, 12)
        }

        Color.clear.frame(height: 180)

      }

      .padding(.horizontal)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .clipped()
  }

  // Helper function to get flairs for the shot
  func getFlairs(currShot: Shot, nextShot: Shot?, currDistance: Int, index: Int)
    -> [Flair]
  {
    var flairs: [Flair] = []
    if nextShot != nil {
      // Big shot flair
      if currDistance > 200 {
        flairs.append(
          Flair(label: "⚡ Big move", colour: .yellow200)
        )
      }
      // Hitting a close shot
      if currDistance > 50 && nextShot!.distanceToPin! < currDistance / 10 {
        flairs.append(
          Flair(label: "🎯 Solid shot", colour: .green200)
        )
      }
      // Short shot
      if currDistance < 30 {
        flairs.append(
          Flair(label: "🪶 Touch shot", colour: .blue200)
        )
      }
      // Bad shot
      if ((currDistance < nextShot!.distanceToPin!)
        || (nextShot!.distanceToPin! > currShot.distanceToPin! / 2))
        && !(hole.par == 5)
      {
        flairs.append(
          Flair(label: "💥 Mishit", colour: .red200)
        )
      }
    } else {
      // Pick up - if no next shot and it doesn't equal the score on the hole
      if (index + 1) != score {
        flairs.append(
          Flair(label: "📦 Packed it in", colour: .brown200)
        )
      }
      // Hole out or big putt
      else if currShot.distanceToPin! > 10 {
        flairs.append(
          Flair(label: "💣 Dropped a bomb!", colour: .orange200)
        )
      }
    }
    return flairs
  }
}

// Shots card
struct ShotsCard: View {
  let shot: Shot
  let distance: Int
  let shotType: String
  let flairs: [Flair]

  var body: some View {
    GeometryReader { geo in
      HStack {
        // Left side of the stack, shot details except distance
        VStack(alignment: .leading, spacing: 4) {
          // Flairs at the top
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
              Badge(
                text: shotType,
                colour: .accentGreen,
                size: 10
              )
              ForEach(flairs) { flair in
                Badge(
                  text: flair.label,
                  colour: flair.colour,
                  size: 10
                )
                .padding(.horizontal, 4)
              }
            }
          }
          // Distance to the pin
          Text("\(shot.distanceToPin!)m to pin")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.content)
          HStack(spacing: 0) {
            Text("Location: ")
              .font(.system(size: 12, weight: .bold))
              .foregroundStyle(.content)
            Text(String(format: "%.4f°, ", shot.userLat!))
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(.content)
            Text(String(format: "%.4f°", shot.userLong!))
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(.content)
          }
        }
        .frame(width: geo.size.width * 0.75, alignment: .leading)
        Divider()
          .frame(width: 1)
          .overlay(
            Rectangle()
              .frame(width: 3)
              .foregroundColor(Color.base300)
              .cornerRadius(10)
          )
        // Distance of the shot
        Text("\(distance)m")
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(.content)
          .frame(width: geo.size.width * 0.2, alignment: .center)
      }
      .frame(
        width: geo.size.width,
        height: geo.size.height,
        alignment: .leading
      )

    }
    .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
    .padding(8)
    .background(.base200)
    .cornerRadius(12)

  }
}

#Preview {
  let testHole = Hole(
    tee_lat: -37.840217196015125,
    tee_lng: 145.09999076907312,
    green_lat: -37.8384012989252,
    green_lng: 145.100180946968,
    num: 6,
    par: 4
  )

  let testShots: [Shot] = [
    Shot(
      id: "aQv5iHykfRixx9URaM1H",
      distanceToPin: 271,
      time: 1742978144.133455,
      userLat: -38.380177,
      userLong: 144.89792809985494
    ),
    Shot(
      id: "KvVZtwIJtVUCkZMAynPu",
      distanceToPin: 79,
      time: 1742978189.2742,
      userLat: -38.381624,
      userLong: 144.8961089275216
    ),
    Shot(
      id: "vtHHuHo8yAtkCz1wei6o",
      distanceToPin: 42,
      time: 1742978218.4290009,
      userLat: -38.381932,
      userLong: 144.89626798274705
    ),
  ]
  ShotsSheetView(shots: testShots, hole: testHole, score: 3).environmentObject(
    SheetPositionHandler()
  )
}
