//
//  RoundMapView.swift
//  Greenside
//
//  Created by Oskar Hosken on 16/5/2025.
//

import Foundation
import MapKit
import SwiftUI

// Our MapView from UIKit
struct RoundMapView: UIViewRepresentable {
  @EnvironmentObject private var viewModel: CoursesViewModel
  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  private let mapManager = MapManager()
  
  // The shots that we made on this hole
  let shots: [Shot]

  var region: MKCoordinateRegion
  var camera: MKMapCamera
  let mapType: MapType

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
    mapView.mapType = .standard
    mapView.isUserInteractionEnabled = false // False for now
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false
    
    // Adding annotations for each shot onto the map
    mapView.addAnnotations(shots.map { shot in
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(
        latitude: shot.userLat!,
        longitude: shot.userLong!
      )
      annotation.title = "\(shot.distanceToPin ?? 0)m"
      return annotation
    })

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    // Updating map type
    mapView.mapType = mapType == .standard ? .standard : .satellite
    
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
  }
}
