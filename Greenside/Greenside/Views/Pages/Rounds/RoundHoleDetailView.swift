//
//  RoundHoleDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 16/5/2025.
//

import SwiftUI

enum SheetPosition: CGFloat {
  case bottom = 1.0
  case third = 0.67
  case full = 0.0
}

class SheetPositionHandler: ObservableObject {
  @Published var position: SheetPosition = .bottom
}

struct RoundHoleDetailView: View {
  @EnvironmentObject private var coursesViewModel: CoursesViewModel
  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility

  @StateObject private var sheetPosition = SheetPositionHandler()

  private let mapManager = MapManager()

  @State private var selectedShot: Shot?

  @State var hole: Hole
  @State var shots: [Shot]

  // For testing sheet behaviour
  @State private var isSheetPresented: Bool = false

  @GestureState private var dragOffset: CGFloat = 0

  var body: some View {
    let region = mapManager.fitRegion(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )
    let camera = mapManager.setCamera(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )

    let distance = String(format: "%.0f", hole.distance)

    ZStack {
      Color.base200.ignoresSafeArea()
      VStack(alignment: .leading) {
        HStack {
          VStack(alignment: .leading) {

            Text("Hole \(hole.num)")
              .font(.system(size: 32, weight: .bold))
              .foregroundStyle(.content)
            Text("Par \(hole.par) · \(distance)m")
              .font(.system(size: 24, weight: .medium))
              .foregroundStyle(.content)
            Button {
              isSheetPresented.toggle()
            } label: {
              Image(systemName: "figure.golf")
            }

          }
          Spacer()
          let score = roundsViewModel.currentHole?.score
          ScoreCell(score: score ?? hole.par + 2, par: hole.par)
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        ScrollView {
          VStack {
            RoundMapView(
              shots: $shots,
              region: region,
              camera: camera,
              mapType: .standard
            )
            .frame(height: 700)
          }

        }
      }
      GeometryReader { geo in
        let totalHeight = geo.size.height
        let peekHeight: CGFloat = 20

        let snapPoints: [(SheetPosition, CGFloat)] = [
          (.bottom, totalHeight - peekHeight),
          (.third, totalHeight * 0.67 - peekHeight),
          (.full, 100),
        ]
        let snappedOffset =
          snapPoints.first(where: { $0.0 == sheetPosition.position })?.1
          ?? (totalHeight - peekHeight)

        VStack {
          Spacer()
          ShotsSheet(shots: shots)
            .environmentObject(sheetPosition)
            .frame(height: totalHeight)
            .offset(y: max(snappedOffset + dragOffset, 0))
            .gesture(
              DragGesture()
                .updating($dragOffset) { value, state, _ in
                  state = value.translation.height
                }
                .onEnded { value in
                  let endOffset = snappedOffset + value.translation.height
                  let nearest =
                    snapPoints.min(by: {
                      abs($0.1 - endOffset) < abs($1.1 - endOffset)
                    })?.0 ?? .bottom
                  sheetPosition.position = nearest
                }
            )
        }
        .onChange(of: isSheetPresented) { newValue in
          withAnimation(.easeInOut(duration: 0.2)) {
            sheetPosition.position = newValue ? .third : .bottom
          }
        }
        .onChange(of: sheetPosition.position) { newValue in
          withAnimation(.easeInOut(duration: 0.2)) {
            sheetPosition.position = newValue
          }
        }
      }
      bottomBar

    }

    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(roundsViewModel.currentRound?.title ?? "")
          .foregroundColor(.content)
          .font(.system(size: 16, weight: .bold))
      }
    }

    .onAppear {
      // Disabling the tab bar
      tabBarVisibility.isVisible = false
      // Setting the current hole in the rounds view model
      if roundsViewModel.currentRound != nil {
        roundsViewModel.currentHole = roundsViewModel.roundHoles[hole.num - 1]
      }

    }
    .onDisappear {
      tabBarVisibility.isVisible = true
    }
  }

  // Bottom bar for controlling navigation between holes
  private var bottomBar: some View {

    let hasPrev =
      roundsViewModel.previousHole(current: hole.num) != nil
    let hasNext =
      roundsViewModel.nextHole(current: hole.num) != nil

    return
      VStack {
        Spacer()
        HStack {
          Button {
            if let prevHole = roundsViewModel.previousHole(current: hole.num) {
              hole = prevHole
              roundsViewModel.currentHole =
                roundsViewModel.roundHoles[prevHole.num - 1]
              print(roundsViewModel.roundShots[prevHole.num]!)
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
            if let nextHole = roundsViewModel.nextHole(current: hole.num) {
              hole = nextHole
              roundsViewModel.currentHole =
                roundsViewModel.roundHoles[nextHole.num - 1]
              print(roundsViewModel.roundShots[nextHole.num]!)
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

private struct ShotsSheet: View {
  let shots: [Shot]

  @EnvironmentObject private var sheetPosition: SheetPositionHandler

  var body: some View {
    VStack {
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
        if sheetPosition.position != .bottom {
          Button {
            sheetPosition.position = .bottom
          } label: {
            Image(systemName: "x.circle")
              .font(.system(size: 24, weight: .medium))
              .foregroundStyle(.base400)
              .frame(width: 30)
          }

        } else {
          Spacer().frame(width: 30)
        }

      }
      .padding(.horizontal)
      Spacer()
    }
    .padding(.top, 12)
    .background(.base100)
    .cornerRadius(12)

  }
}

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

  // Outline view chosen by diff
  @ViewBuilder private var outline: some View {
    switch diff {
    case ..<(-1): doubleCircle
    case -1: singleCircle
    case 0: EmptyView()  // par – no outline
    case 1: singleRounded
    default: doubleRounded
    }
  }

  // MARK: - Colour helpers
  private var outlineColour: Color {
    switch diff {
    case ..<(-1): return .accentGreen  // eagle or better
    case -1: return .lightRed  // birdie
    case 0: return .base100  // not used
    default: return .lightBlue  // bogey or worse
    }
  }

  // MARK: - Shapes
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
