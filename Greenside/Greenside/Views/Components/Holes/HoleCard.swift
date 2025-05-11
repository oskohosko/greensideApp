//
//  HoleCard.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import CoreLocation
import SwiftUI
import MapKit

struct HoleCard: View {
  @EnvironmentObject private var viewModel: CoursesViewModel
  private let mapManager = MapManager()
  
  @State private var isHolePresented = false
  @State private var annotations: [MKPointAnnotation] = []
  @State private var overlays: [MKOverlay] = []

  let hole: Hole
  let mapType: MapType
  
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
  
  let score: Int? = 0
  
  // Classifying score
  func classifyScore() -> (String, Color) {
    if let score = score, score != 0 {
      let diff = score - hole.par
      switch diff {
        case ..<(-1):
          return ("Eagle", .accentGreen)
        case (-1):
          return ("Birdie", .lightRed)
        case (0):
          return ("Par", .base200)
        case (1):
          return ("Bogey", .lightBlue)
        default:
          return ("Double Bogey+", .lightBlue)
      }
    } else {
      return ("-", .base100)
    }
    
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

    Button {
      isHolePresented.toggle()
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
        .fullScreenCover(isPresented: $isHolePresented) {
          HoleDetailFullScreen(hole: hole)
            .environmentObject(viewModel)
        }

        MapView(
          annotations: $annotations,
          overlays: $overlays,
          region: region,
          camera: camera,
          interactive: false,
          mapType: mapType,
          isChangingHole: false
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        // If we have sent a score to this view, add a badge
        if score != 0 {
          let (text, colour) = classifyScore()
          Badge(
            text: text,
            colour: colour,
            size: 10
          )
        }
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
  HoleCard(hole: testHole, mapType: .standard).environmentObject(
    CoursesViewModel()
  )
}
