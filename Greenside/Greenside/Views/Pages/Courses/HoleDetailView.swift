//
//  HoleDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import SwiftUI

struct HoleDetailView: View {
  @State var hole: Hole
  @EnvironmentObject private var viewModel: CoursesViewModel
  private let mapManager = MapManager()

  var body: some View {
    // Using our mapManager to get the region and camera
    let region = mapManager.fitRegion(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )
    let camera = mapManager.setCamera(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )

    ZStack {
      Color.base200.ignoresSafeArea()
      VStack(spacing: 0) {
        HStack {
          Text("Hole \(hole.num)")
            .font(.system(size: 32, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.content)
          Spacer()
          Image(systemName: "list.bullet")
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(.content)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        MapView(
          region: region,
          camera: camera,
          interactive: true,
          mapType: .satellite
        )

        let hasPrev = viewModel.previousHole(current: hole) != nil
        let hasNext = viewModel.nextHole(current: hole) != nil

        HStack {

          // Previous Hole
          Button {
            if let prev = viewModel.previousHole(current: hole) {
              hole = prev
            }
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "arrow.left")
                .font(.system(size: 36, weight: .medium))
              Text("Previous Hole")
                .font(.system(size: 12))
            }
            .foregroundStyle(hasPrev ? .content : .base400)
          }
          .disabled(!hasPrev)
          .frame(maxWidth: .infinity)

          Button {

          } label: {
            Image(systemName: "plus.circle.fill")
              .font(.system(size: 44, weight: .bold))
              .foregroundStyle(.accentGreen)
          }
          .frame(maxWidth: .infinity)

          // Next Hole
          Button {
            if let next = viewModel.nextHole(current: hole) {
              hole = next
            }
          } label: {
            VStack(spacing: 2) {
              Image(systemName: "arrow.right")
                .font(.system(size: 36, weight: .medium))
              Text("Next Hole")
                .font(.system(size: 12))
            }
            .foregroundStyle(hasNext ? .content : .base400)
          }
          .disabled(!hasNext)
          .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .background(Color.base200)
      }

    }
    // Removes the tab bar for this view
    .onAppear {
      withAnimation {
        viewModel.isTabBarHidden = true
      }
    }
    .onDisappear {
      withAnimation {
        viewModel.isTabBarHidden = false
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        VStack {
          Text(viewModel.selectedCourse?.name ?? "Course")
            .foregroundColor(.content)
            .font(.system(size: 16, weight: .regular))
          Text("\(String(format: "%.0f", hole.distance))m · Par \(hole.par)")
            .foregroundColor(.content)
            .font(.system(size: 16, weight: .bold))
        }

      }
    }

  }
}

struct CustomCorners: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
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
  HoleDetailView(hole: testHole).environmentObject(CoursesViewModel())
}
