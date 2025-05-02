//
//  HoleDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import MapKit  // ← only if MapView lives here
import SwiftUI

struct HoleDetailView: View {
  @State var hole: Hole
  @EnvironmentObject private var viewModel: CoursesViewModel
  private let mapManager = MapManager()

  // MARK: – Computed map region
  private var region: MKCoordinateRegion {
    mapManager.fitRegion(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )
  }
  private var camera: MKMapCamera {
    mapManager.setCamera(
      tee: hole.teeLocation,
      green: hole.greenLocation
    )
  }

  var body: some View {
    // Map first, everything else overlays
    ZStack {
      MapView(
        region: region,
        camera: camera,
        interactive: true,
        mapType: .satellite
      )
      .ignoresSafeArea()

      // Overlays
      VStack(spacing: 0) {
        HStack {
          Text("Hole \(hole.num)")
            .font(.system(size: 32, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)

          Image(systemName: "list.bullet")
            .font(.system(size: 28, weight: .medium))
            .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.clear)

        Spacer()

        bottomBar
          .padding(.vertical, 8)
        Spacer().frame(height: 40)
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
        VStack {
          Text(viewModel.selectedCourse?.name ?? "Course")
            .foregroundColor(.white)
            .font(.system(size: 16))

          Text("\(String(format: "%.0f", hole.distance))m · Par \(hole.par)")
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .bold))
        }
      }
    }
    .toolbarBackground(.hidden, for: .navigationBar)
    .toolbarColorScheme(.dark, for: .navigationBar)
  }
  private var bottomBar: some View {
    let hasPrev = viewModel.previousHole(current: hole) != nil
    let hasNext = viewModel.nextHole(current: hole) != nil

    return HStack {

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
        .foregroundColor(hasPrev ? .white : .base200)
      }
      .disabled(!hasPrev)
      .frame(maxWidth: .infinity)

      // Add-shot button
      Button {
        // Action goes here
      } label: {
        Image(systemName: "plus.circle.fill")
          .font(.system(size: 44, weight: .bold))
          .foregroundColor(.white)
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
        .foregroundColor(hasNext ? .white : .base400)
      }
      .disabled(!hasNext)
      .frame(maxWidth: .infinity)
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
