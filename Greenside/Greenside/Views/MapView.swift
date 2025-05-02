//
//  MapView.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import Foundation
import MapKit
import SwiftUI

// Our MapView from UIKit
struct MapView: UIViewRepresentable {
  var region: MKCoordinateRegion
  var camera: MKMapCamera
  let interactive: Bool
  let mapType: MapType

  // Doing it this way allows us to alter the camera position and more
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.setRegion(region, animated: true)
    mapView.camera = camera
    mapView.mapType = .standard
    mapView.isUserInteractionEnabled = interactive
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    mapView.setRegion(region, animated: true)
    mapView.camera = camera
    mapView.mapType = mapType == .standard ? .standard : .satellite
  }
}
