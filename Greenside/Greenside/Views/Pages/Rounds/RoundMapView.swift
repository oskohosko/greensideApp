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
  @Binding var shots: [Shot]

  var region: MKCoordinateRegion
  var camera: MKMapCamera
  let mapType: MapType

  // Coordinator to handle custom annotations
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
    mapView.mapType = .standard
    mapView.isUserInteractionEnabled = false  // False for now
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false
    
    // Registering shot annotation
    mapView.register(ShotAnnotationView.self,
                      forAnnotationViewWithReuseIdentifier: ShotAnnotationView.reuseID)
      
    // Adding annotations for each shot onto the map
    mapView.addAnnotations(
      shots.map { shot in
        ShotAnnotation(shot: shot)
      }
    )

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    
    // Removing previouse annotations
    mapView.removeAnnotations(mapView.annotations)
    
    // Adding new ones
    mapView.addAnnotations(
      shots.map { shot in
        ShotAnnotation(shot: shot)
      }
    )
    
    // Updating map type
    mapView.mapType = mapType == .standard ? .standard : .satellite

    mapView.setRegion(region, animated: false)
    mapView.camera = camera
  }

  final class Coordinator: NSObject, MKMapViewDelegate {
    var parent: RoundMapView

    init(_ parent: RoundMapView) {
      self.parent = parent
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
      -> MKAnnotationView? {
      // Ensuring the annotation is a ShotAnnotation
      guard let shotAnnotation = annotation as? ShotAnnotation else {
        return nil
      }

      var annotationView =
        mapView.dequeueReusableAnnotationView(
          withIdentifier: ShotAnnotationView.reuseID
        ) as? ShotAnnotationView

      if annotationView == nil {
        annotationView = ShotAnnotationView(
          annotation: shotAnnotation,
          reuseIdentifier: ShotAnnotationView.reuseID
        )
      } else {
        annotationView?.annotation = shotAnnotation
      }

      return annotationView
    }
  }

}
