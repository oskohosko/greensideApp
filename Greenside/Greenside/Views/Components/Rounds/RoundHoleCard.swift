//
//  RoundHoleCard.swift
//  Greenside
//
//  Created by Oskar Hosken on 16/5/2025.
//

import CoreLocation
import MapKit
import SwiftUI

struct RoundHoleCard: View {
  @EnvironmentObject private var coursesViewModel: CoursesViewModel
  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility
  
  private let mapManager = MapManager()

  let hole: Hole
  
  @State var shots: [Shot]

  @State var mapType: MapType

  private var distance: String {
    return String(
      format: "%.0f",
      distanceBetweenPoints(
        first: CLLocationCoordinate2D(
          latitude: hole.tee_lat,
          longitude: hole.tee_lng
        ),
        second: CLLocationCoordinate2D(
          latitude: hole.green_lat,
          longitude: hole.green_lng
        ),
      )
    )
  }

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

    NavigationLink {
      // Navigates to the hole view
      RoundHoleDetailView(
        hole: hole,
        shots: shots
        )
      .environmentObject(coursesViewModel)
      .environmentObject(roundsViewModel)
      .environmentObject(tabBarVisibility)
    } label: {
      VStack(alignment: .leading, spacing: 2) {
        Text("Hole \(hole.num)")
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.content)
        HStack {
          HStack(spacing: 2) {
            Image(systemName: "mappin.circle.fill")
              .foregroundStyle(.accentGreen)
              .font(.system(size: 10))
            Text("Par \(hole.par)")
              .font(.system(size: 10, weight: .medium))
              .foregroundStyle(.content)
          }
          Spacer()
          HStack(spacing: 2) {
            Image(systemName: "flag.circle.fill")
              .foregroundStyle(.lightRed)
              .font(.system(size: 10))
            Text("\(distance)m")
              .font(.system(size: 10, weight: .medium))
              .foregroundStyle(.content)

          }
        }
        .padding(.bottom, 4)
        RoundMapView(
          hole: hole,
          shots: $shots,
          region: region,
          camera: camera,
          mapType: $mapType,
          annotationSize: 10,
          interactive: false,
          isChangingHole: false
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
    .padding(.horizontal, 6)
    .padding(.vertical, 4)
    .padding(.bottom, 2)
    .frame(width: 120, height: 180)
    .background(.base100)
    .cornerRadius(15)

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
  RoundHoleCard(hole: testHole, shots: [],  mapType: .standard)
    .environmentObject(CoursesViewModel())
    .environmentObject(RoundsViewModel())
    .environmentObject(TabBarVisibility())
}
