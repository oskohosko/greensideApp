//
//  AddShotsView.swift
//  Greenside
//
//  Created by Oskar Hosken on 3/6/2025.
//

import SwiftUI

// View for adding shots to a hole
struct AddShotsView: View {

  @EnvironmentObject private var vm: RoundCreationVM
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility
  private let mapManager = MapManager()

  @State private var score: Int = 0
  @State private var shots: [Shot] = []

  @State var hole: Hole

  private var holeDistance: String {
    String(format: "%.0f", hole.distance)
  }

  // Popup
  @State private var popup: PopupConfig?

  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          VStack(alignment: .leading) {
            Text("Hole \(hole.num)")
              .font(.system(size: 32, weight: .bold))
              .foregroundStyle(.content)
            Text("Par \(hole.par) · \(holeDistance)m")
              .font(.system(size: 24, weight: .medium))
              .foregroundStyle(.content)

          }
          Spacer()
          ScoreCell(score: $score, par: hole.par)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)

        // Map Section with navigation
        ZStack {
          GeometryReader { geo in
            AddRoundMapView(
              shots: $shots,
              hole: hole,
              region: mapManager.fitRegion(
                tee: hole.teeLocation,
                green: hole.greenLocation
              ),
              camera: mapManager.setCamera(
                tee: hole.teeLocation,
                green: hole.greenLocation
              )
            )
            .frame(width: geo.size.width, height: geo.size.height + 40)
            .ignoresSafeArea()
          }
          // Bottom bar ontop of map
          let hasPrev = vm.previousHole(current: hole.num) != nil
          let hasNext = vm.nextHole(current: hole.num) != nil
          VStack {
            Spacer()
            HStack {
              // Previous hole
              Button {
                if hasPrev {
                  vm.isChangingHole = true
                  hole = vm.previousHole(current: hole.num)!
                  // Fetching shots for this hole from the VM for now
                  shots = vm.roundShots[hole.num] ?? []
                  
                }
              } label: {
                VStack(spacing: 0) {
                  Image(systemName: "arrowshape.left.circle.fill")
                    .font(.system(size: 42))
                  Text("Previous")
                    .font(.system(size: 12))
                }
                .foregroundStyle(.white)
              }
              .disabled(!hasPrev)
              Spacer()
              // Next hole
              Button {
                if hasNext {
                  vm.isChangingHole = true
                  hole = vm.nextHole(current: hole.num)!
                  // Fetching shots for this hole from the VM for now
                  shots = vm.roundShots[hole.num] ?? []
                  
                }
              } label: {
                VStack(spacing: 0) {
                  Image(systemName: "arrowshape.right.circle.fill")
                    .font(.system(size: 42))
                  Text("Next")
                    .font(.system(size: 12))
                }
                .foregroundStyle(.white)
              }
              .disabled(!hasNext)
            }
          }
          .padding(.horizontal, 8)
          .padding(.bottom, 16)
        }
      }
      .frame(maxHeight: .infinity, alignment: .top)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          // Save shots on hole and present a message
          vm.roundShots[hole.num] = shots
          popup = PopupConfig(message: "Shots saved!", style: .success)
        } label: {
          Text("Save")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white)
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background(.accentGreen)
            .cornerRadius(16)

        }
      }
    }
    .onAppear {
      // Removing tab view
      tabBarVisibility.isVisible = false
      // Fetching shots for this hole from the VM for now
      if let saved = vm.roundShots[hole.num] {
        shots = saved
        vm.needsMapRefresh = true
      }
    }
    .onDisappear {
      tabBarVisibility.isVisible = true
    }
    .onChange(of: hole.num) {
      vm.isChangingHole = false
    }
    .onChange(of: shots) {
      score = shots.count
    }
    .popup($popup)
  }
}

// Score cell for classifying our score
private struct ScoreCell: View {
  @Binding var score: Int
  let par: Int

  private var diff: Int { score - par }

  var body: some View {
    Text("\(score)")
      .font(.system(size: 36, weight: .bold))
      .frame(width: 54, height: 54)
      .overlay(outline)
      .foregroundStyle(.content)
  }

  @ViewBuilder private var outline: some View {
    switch diff {
    case ..<(-1): doubleCircle
    case -1: singleCircle
    case 0: EmptyView()
    case 1: singleRounded
    default: doubleRounded
    }
  }

  private var outlineColour: Color {
    switch diff {
    case ..<(-1): return .accentGreen
    case -1: return .lightRed
    case 0: return .base100
    default: return .lightBlue
    }
  }

  private var singleCircle: some View {
    Circle().stroke(outlineColour, lineWidth: 3)
  }

  private var doubleCircle: some View {
    Circle().stroke(outlineColour, lineWidth: 3)
      .overlay(Circle().inset(by: 5).stroke(outlineColour, lineWidth: 3))
  }

  private var singleRounded: some View {
    RoundedRectangle(cornerRadius: 6).stroke(outlineColour, lineWidth: 3)
  }

  private var doubleRounded: some View {
    RoundedRectangle(cornerRadius: 6).stroke(outlineColour, lineWidth: 3)
      .overlay(
        RoundedRectangle(cornerRadius: 6).inset(by: 5).stroke(
          outlineColour,
          lineWidth: 3
        )
      )
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
  AddShotsView(hole: testHole)
    .environmentObject(RoundCreationVM())
    .environmentObject(TabBarVisibility())
}
