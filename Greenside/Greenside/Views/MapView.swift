//
//  MapView.swift
//  Greenside
//
//  Created by Oskar Hosken on 30/5/2025.
//

import Foundation
import MapKit
import SwiftUI

// Basic MapView skeleton. This is used for previews of holes.
struct MapView: UIViewRepresentable {

  private let mapManager = MapManager()
  
  @Binding var mapType: MapType

  var region: MKCoordinateRegion
  var camera: MKMapCamera

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
    mapView.mapType = mapType == .satellite ? .satellite : .standard
    mapView.isUserInteractionEnabled = false
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    
    mapView.mapType = mapType == .satellite ? .satellite : .standard
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
  }
}
