//
//  ShotsSheetView.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/5/2025.
//

import SwiftUI

struct ShotsSheetView: View {
  let shots: [Shot]
  let hole: Hole
  let score: Int

  @EnvironmentObject private var sheetPosition: SheetPositionHandler
  @EnvironmentObject private var roundsViewModel: RoundsViewModel

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
                roundsViewModel.selectedShot = nil
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
      if sheetPosition.position == .full {
        ScrollView(.vertical, showsIndicators: true) {
          VStack(alignment: .leading, spacing: 0) {
            ShotsList(shots: shots, hole: hole, score: score)
              .environmentObject(sheetPosition)
              .environmentObject(roundsViewModel)
          }
          .padding(.trailing, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      } else {
        ScrollView(.horizontal, showsIndicators: true) {
          HStack(alignment: .top, spacing: 8) {
            ShotsList(shots: shots, hole: hole, score: score)
              .environmentObject(sheetPosition)
              .environmentObject(roundsViewModel)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

      }
    }
    .background(.base100)
    .cornerRadius(20)
    .frame(maxHeight: .infinity)

  }

  // List of shots
  struct ShotsList: View {
    let shots: [Shot]
    let hole: Hole
    let score: Int
    @EnvironmentObject private var sheetPosition: SheetPositionHandler
    @EnvironmentObject private var roundsViewModel: RoundsViewModel

    private let mapManager = MapManager()

    // We want to map every shot to a shot card
    var body: some View {
      ScrollViewReader { proxy in
        Group {
          if sheetPosition.position == .full {
            VStack(alignment: .leading, spacing: 0) {
              shotViews
              Color.clear.frame(height: 180)
            }
          } else {
            HStack(alignment: .top, spacing: 8) {
              shotViews
              Color.clear.frame(width: 20)
            }
          }
        }
        .onChange(of: roundsViewModel.selectedShot) { selectedShot in
          guard
            let selectedShot,
            let idx = shots.firstIndex(where: { $0.time == selectedShot.time })
          else { return }

          withAnimation(.easeInOut(duration: 0.3)) {
            if sheetPosition.position != .full {
              proxy.scrollTo("shot-\(idx)", anchor: .leading)
            }
          }
        }
        .onChange(of: roundsViewModel.currentHole) {
          proxy.scrollTo("shot-0", anchor: .leading)
        }
      }
    }

    @ViewBuilder
    private var shotViews: some View {
      ForEach(Array(shots.enumerated()), id: \.offset) { index, shot in
        // Checking if there is a previous or next shot
        let isNext = index < shots.count - 1

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

        // Getting the flairs for this shot
        let currentFlairs: [Flair] = {
          guard !roundsViewModel.holeShotBadges.isEmpty,
            index < roundsViewModel.holeShotBadges.count
          else {
            return []
          }
          return roundsViewModel.holeShotBadges[index]
        }()

        VStack(alignment: .leading, spacing: 2) {
          Text("Shot \(index + 1)")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.content)
            .padding(.bottom, 2)

          ShotsCard(
            shot: shot,
            distance: Int(distanceOfCurrent),
            flairs: currentFlairs
          )
          .padding(.bottom, 12)
        }
        .padding(.leading, 12)
        .id("shot-\(index)")
      }
    }
  }
}

// Shots card
struct ShotsCard: View {
  let shot: Shot
  let distance: Int
  //  let shotType: String
  let flairs: [Flair]

  var body: some View {
    GeometryReader { geo in
      HStack {
        // Left side of the stack, shot details except distance
        VStack(alignment: .leading, spacing: 4) {
          // Flairs at the top
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
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
    .frame(
      minWidth: UIScreen.main.bounds.width - 60,
      maxWidth: .infinity,
      minHeight: 80,
      maxHeight: 80
    )
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
  ShotsSheetView(shots: testShots, hole: testHole, score: 3)
    .environmentObject(
      SheetPositionHandler()
    )
    .environmentObject(RoundsViewModel())
}
