//
//  HoleCard.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import CoreLocation
import SwiftUI

struct HoleCard: View {
  @EnvironmentObject private var viewModel: CoursesViewModel
  private let mapManager = MapManager()

  let hole: Hole

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

    NavigationLink(
      destination: HoleDetailView(hole: hole).environmentObject(viewModel)
    ) {
      VStack(alignment: .leading, spacing: 2) {
        Text("Hole \(hole.num)")
          .font(.system(size: 20, weight: .bold))
          .foregroundStyle(.content)
        HStack {
          HStack(spacing: 2) {
            Image(systemName: "mappin.circle.fill")
              .foregroundStyle(.accentGreen)
            Text("Par \(hole.par)")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.content)
          }
          Spacer()
          HStack(spacing: 2) {
            Image(systemName: "flag.circle.fill")
              .foregroundStyle(.lightRed)
            Text("\(distance)m")
              .font(.system(size: 16, weight: .medium))
              .foregroundStyle(.content)
          }
        }.padding(.bottom, 4)
        
        

        MapView(region: region, camera: camera, interactive: false)
          .clipShape(RoundedRectangle(cornerRadius: 15))
      }

    }
    .padding(.horizontal)
    .padding(.vertical, 8)
    .frame(width: 180, height: 320)
    .background(.base100)
    .cornerRadius(20)
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
  HoleCard(hole: testHole).environmentObject(CoursesViewModel())
}
