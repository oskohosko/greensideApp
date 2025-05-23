//
//  RoundHoleDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 16/5/2025.
//

import SwiftUI

// Enum for our shot sheet position
enum SheetPosition: CGFloat {
  case bottom = 1.0
  case third = 0.67
  case full = 0.0
}

class SheetPositionHandler: ObservableObject {
  @Published var position: SheetPosition = .bottom
}

struct RoundHoleDetailView: View {
  // Environment Objects
  @EnvironmentObject private var coursesViewModel: CoursesViewModel
  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility

  @StateObject private var sheetPosition = SheetPositionHandler()

  private let mapManager = MapManager()

  // State for the shots sheet
  @State private var selectedShot: Shot?
  @State var hole: Hole
  @State var shots: [Shot]
  @State private var isChangingHole: Bool = false
  @State private var isSheetPresented: Bool = false
  @GestureState private var dragOffset: CGFloat = 0

  // Map state
  @State private var mapType: MapType = .standard

  var body: some View {
    ZStack {
      // Background colour
      Color.base200.ignoresSafeArea()
      VStack(alignment: .leading) {
        // Header
        HeaderView(
          hole: hole,
          score: roundsViewModel.currentHole?.score ?? 0,
          distance: holeDistance,
          isSheetPresented: $isSheetPresented
        )
        .padding(.top, 32)
        // Map View section
        RoundMapViewContainer(
          hole: hole,
          shots: $shots,
          isChangingHole: $isChangingHole,
          mapType: $mapType
        )
      }
      // The overlay of the sheet
      SheetView(
        sheetPosition: sheetPosition,
        isSheetPresented: $isSheetPresented,
        totalHeight: UIScreen.main.bounds.height
      )
      // Bottom section for hole navigation
      bottomBar
        .padding(.bottom, 76)
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(roundsViewModel.currentRound?.title ?? "")
          .foregroundColor(.content)
          .font(.system(size: 16, weight: .bold))
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          // Toggling the map type
          if mapType == .standard {
            mapType = .satellite
          } else {
            mapType = .standard
          }
        } label: {
          Image(
            systemName: mapType == .standard ? "map.circle" : "map.circle.fill"
          )
          .font(.system(size: 24, weight: .medium))
          .foregroundStyle(.accentGreen)
        }
      }
    }
    .onAppear {
      // Removing tab bar on appear
      tabBarVisibility.isVisible = false
      // And setting current hole in our view model
      if roundsViewModel.currentRound != nil {
        roundsViewModel.currentHole = roundsViewModel.roundHoles[hole.num - 1]
      }
    }
    // Adding tab bar back
    .onDisappear {
      tabBarVisibility.isVisible = true
    }
    .onChange(of: hole.num) {
      isChangingHole = false
    }
  }

  private var holeDistance: String {
    String(format: "%.0f", hole.distance)
  }

  private var bottomBar: some View {
    BottomBarView(hole: $hole, shots: $shots, isChangingHole: $isChangingHole)
      .environmentObject(roundsViewModel)
  }
}

// Header view
private struct HeaderView: View {
  let hole: Hole
  let score: Int
  let distance: String
  @Binding var isSheetPresented: Bool

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("Hole \(hole.num)")
          .font(.system(size: 32, weight: .bold))
          .foregroundStyle(.content)
        Text("Par \(hole.par) · \(distance)m")
          .font(.system(size: 24, weight: .medium))
          .foregroundStyle(.content)

      }
      Spacer()
      ScoreCell(score: score, par: hole.par)
    }
    .padding(.top, 8)
    .padding(.horizontal, 16)
  }
}

// View for our map view section
private struct RoundMapViewContainer: View {
  let hole: Hole
  @Binding var shots: [Shot]
  @Binding var isChangingHole: Bool
  @Binding var mapType: MapType

  private let mapManager = MapManager()

  var body: some View {
    // Getting regions from the map manager
    let region = mapManager.fitRegion(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )
    let camera = mapManager.setCamera(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )

    VStack {
      RoundMapView(
        hole: hole,
        shots: $shots,
        region: region,
        camera: camera,
        mapType: $mapType,
        annotationSize: 16,
        interactive: true,
        isChangingHole: isChangingHole
      )
      .frame(height: 668)
    }
  }
}

// Sheet view
private struct SheetView: View {
  @ObservedObject var sheetPosition: SheetPositionHandler
  @Binding var isSheetPresented: Bool
  let totalHeight: CGFloat
  // Offset for dragging gesture
  @GestureState private var dragOffset: CGFloat = 0

  var body: some View {
    GeometryReader { geo in
      let totalHeight = geo.size.height
      let peekHeight: CGFloat = 80

      // Points to snap the sheet to when dragging
      let snapPoints: [(SheetPosition, CGFloat)] = [
        (.bottom, totalHeight - peekHeight),
        (.third, totalHeight * 0.67 - peekHeight),
        (.full, 120),
      ]
      // getting offset from the enum
      let snappedOffset =
        snapPoints.first(where: { $0.0 == sheetPosition.position })?.1
        ?? (totalHeight - peekHeight)

      VStack {
        Spacer()
        ShotsSheetView(shots: [])
          .environmentObject(sheetPosition)
          .frame(height: totalHeight)
          .offset(y: max(snappedOffset + dragOffset, 0))
          .gesture(
            DragGesture()
              .updating($dragOffset) { value, state, _ in
                // While dragging, update the position of the sheet
                state = value.translation.height
              }
              .onEnded { value in

                // When sheet dragging has ended, we need to find where to snap to
                let endOffset = snappedOffset + value.translation.height
                // Velocity is used for the quick swipe
                let velocity = value.velocity.height
                let swipeThreshold: CGFloat = 800

                // Getting the current index of where we are swiping from
                guard
                  let currentIdx = snapPoints.firstIndex(where: {
                    $0.0 == sheetPosition.position
                  })
                else {
                  return
                }

                // Setting target index to current one for now
                var targetIdx = currentIdx

                // If we have swiped down, snap to next one down
                if velocity < -swipeThreshold
                  && currentIdx < snapPoints.count - 1
                {
                  targetIdx = currentIdx + 1
                  // Otherwise snap up
                } else if velocity > swipeThreshold && currentIdx > 0 {
                  targetIdx = currentIdx - 1
                  // Otherwise find the nearest one
                } else {
                  targetIdx =
                    snapPoints.enumerated().min(by: {
                      abs($0.element.1 - endOffset)
                        < abs($1.element.1 - endOffset)
                    })?.offset ?? currentIdx
                }

                sheetPosition.position = snapPoints[targetIdx].0

              }
          )
      }
      .onChange(of: isSheetPresented) { newValue in
        withAnimation(.easeInOut(duration: 0.2)) {
          sheetPosition.position = newValue ? .third : .bottom
        }
      }
    }
  }
}

// Bottom bar for navigating between holes
private struct BottomBarView: View {
  @Binding var hole: Hole
  @Binding var shots: [Shot]
  @Binding var isChangingHole: Bool
  @EnvironmentObject var roundsViewModel: RoundsViewModel

  var body: some View {
    let hasPrev = roundsViewModel.previousHole(current: hole.num) != nil
    let hasNext = roundsViewModel.nextHole(current: hole.num) != nil

    return VStack {
      Spacer()
      HStack {
        Button {
          // Navigate to the previous hole
          if let prevHole = roundsViewModel.previousHole(current: hole.num) {
            isChangingHole = true
            hole = prevHole
            roundsViewModel.currentHole =
              roundsViewModel.roundHoles[prevHole.num - 1]
            shots = roundsViewModel.roundShots[prevHole.num] ?? []
          }
        } label: {
          Image(systemName: "arrowshape.left.circle.fill")
            .font(.system(size: 36))
            .foregroundStyle(.white)
        }
        .disabled(!hasPrev)
        Spacer()
        Button {
          // Navigate to the next hole
          if let nextHole = roundsViewModel.nextHole(current: hole.num) {
            isChangingHole = true
            hole = nextHole
            roundsViewModel.currentHole =
              roundsViewModel.roundHoles[nextHole.num - 1]
            shots = roundsViewModel.roundShots[nextHole.num] ?? []
          }
        } label: {
          Image(systemName: "arrowshape.right.circle.fill")
            .font(.system(size: 36))
            .foregroundStyle(.white)
        }
        .disabled(!hasNext)
      }
      .padding(.horizontal, 16)
    }
  }
}

// Score cell for classifying our score
private struct ScoreCell: View {
  let score: Int
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
  RoundHoleDetailView(hole: testHole, shots: [])
    .environmentObject(RoundsViewModel())
    .environmentObject(CoursesViewModel())
    .environmentObject(TabBarVisibility())
}
