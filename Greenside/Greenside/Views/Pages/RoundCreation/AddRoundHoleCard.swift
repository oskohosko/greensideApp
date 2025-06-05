//
//  AddRoundHoleCard.swift
//  Greenside
//
//  Created by Oskar Hosken on 3/6/2025.
//

import MapKit
import SwiftUI

struct AddRoundHoleCard: View {
  @EnvironmentObject private var vm: RoundCreationVM
  @EnvironmentObject private var tabBarVM: TabBarVisibility
  private let mapManager = MapManager()

  let hole: Hole

  @Binding var mapType: MapType
  
  @State private var savedShots: [Shot] = []

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
      // Navigating to add shots view
      AddShotsView(hole: hole)
        .environmentObject(vm)
        .environmentObject(tabBarVM)
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
        
        MapView(
          mapType: $mapType,
          region: region,
          camera: camera
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 4)
        
        // Badge to present if shots have been saved or not
        if !savedShots.isEmpty {
          Badge(
            text: "Saved",
            colour: .accentGreen,
            image: "checkmark.circle",
            size: 10
          )
          .frame(width: 104, alignment: .center)
        } else {
          Badge(
            text: "Unsaved",
            colour: .base200,
            image: "exclamationmark.triangle.fill",
            size: 10
          )
          .frame(width: 104, alignment: .center)
        }
      
      }

    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .padding(.bottom, 4)
    .frame(width: 120, height: 220)
    .background(.base100)
    .cornerRadius(15)
    .onAppear {
      // Fetching saved shots if they exist
      if let saved = vm.roundShots[hole.num] {
        savedShots = saved
      }
    }
  }
}

#Preview {
  @Previewable @State var mapType: MapType = .standard

  let testHole = Hole(
    tee_lat: -37.840217196015125,
    tee_lng: 145.09999076907312,
    green_lat: -37.8384012989252,
    green_lng: 145.100180946968,
    num: 6,
    par: 4
  )
  AddRoundHoleCard(hole: testHole, mapType: $mapType)
    .environmentObject(RoundCreationVM())
    .environmentObject(TabBarVisibility())
}
