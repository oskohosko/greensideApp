//
//  HoleDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import MapKit
import SwiftData
import SwiftUI

struct HoleDetailView: View {
  @State var hole: Hole
  @State private var overlays: [MKOverlay] = []
  @State private var annotations: [MKPointAnnotation] = []
  @State private var isChangingHole: Bool = false

  @EnvironmentObject private var viewModel: CoursesViewModel
  private let mapManager = MapManager()

  // Clubs in the bag
  @Query(sort: \Club.distance, order: .reverse) private var clubs: [Club]

  @State private var selectedClub: Club? = nil
  @State private var clubSheetPresented: Bool = false

  // Might need this check without it
  //  @Environment(\.modelContext) private var context

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
        annotations: $annotations,
        overlays: $overlays,
        region: region,
        camera: camera,
        interactive: true,
        mapType: .satellite,
        isChangingHole: isChangingHole
      )
      .environmentObject(viewModel)
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

        // Sidebar
        VStack {
          HStack {
            Spacer()
            sideBar
          }
          .padding(.horizontal, 16)
          Spacer()
        }

        Spacer()

        // Bottom bar
        bottomBar
          .padding(.vertical, 8)
        Spacer().frame(height: 20)
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
    .onChange(of: hole.num) {
      isChangingHole = false
    }
    .sheet(isPresented: $clubSheetPresented) {
      AddShotSheet(selectedClub: $selectedClub)
        .presentationDetents([.fraction(0.25)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.base200.opacity(0.9))
    }
    // Shot projection logic
    .onChange(of: selectedClub) {
      if let club = selectedClub {
        // Getting the starting point
        let startPoint = viewModel.locationManager.isTrackingLocation ?  viewModel.locationManager.currentLocation!.coordinate : hole.teeLocation
        // End point is distance in direction of green
        // Getting bearing
        let bearing = mapManager.bearingBetweenPoints(
          from: startPoint,
          to: hole.greenLocation
        )
        // Getting the end point
        let endPoint = mapManager.destinationPoint(
          from: startPoint,
          distance: Double(club.distance),
          bearing: bearing
        )
        // And now creating the overlays
        let shotLine = MKPolyline(
          coordinates: [startPoint, endPoint],
          count: 2
        )
        let shotDispersion = MKCircle(
          center: endPoint,
          radius: CLLocationDistance(club.distance) * 0.1
          )
        // Adding the overlay
        overlays = [shotLine, shotDispersion]
      }
      
    }
      
  }

  // Sidebar to go on the right of the view
  private var sideBar: some View {

    return VStack(spacing: 16) {
      Button {
        // Removing overlays
        overlays.removeAll()
        // Toggling location tracking
        if viewModel.locationManager.isTrackingLocation {
          viewModel.locationManager.stopTrackingLocation()
        } else {
          viewModel.locationManager.startTrackingLocation()
        }
      } label: {
        Image(
          systemName: viewModel.locationManager.isTrackingLocation
            ? "location" : "location.slash"
        )
        .font(.system(size: 24, weight: .medium))
        .foregroundStyle(.white)
      }
    }
    .padding(.top, 16)
  }

  private var bottomBar: some View {
    let hasPrev = viewModel.previousHole(current: hole) != nil
    let hasNext = viewModel.nextHole(current: hole) != nil

    return HStack {

      // Previous Hole
      Button {

        if let prev = viewModel.previousHole(current: hole) {
          isChangingHole = true
          hole = prev
          annotations.removeAll()
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

      // Add shot button
      Button {
        // Toggling club projection sheet
        clubSheetPresented.toggle()
      } label: {
        Image(systemName: "plus.circle.fill")
          .font(.system(size: 44, weight: .medium))
          .foregroundColor(.white)
      }
      .frame(maxWidth: .infinity)

      // Next Hole
      Button {
        if let next = viewModel.nextHole(current: hole) {
          isChangingHole = true
          hole = next
          annotations.removeAll()
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
