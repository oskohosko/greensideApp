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

  @EnvironmentObject private var viewModel: CoursesViewModel

  private let mapManager = MapManager()

  @Binding var annotations: [MKPointAnnotation]
  var region: MKCoordinateRegion
  var camera: MKMapCamera
  let interactive: Bool
  let mapType: MapType
  var isChangingHole: Bool

  // Doing it this way allows us to alter the camera position and more
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
    mapView.mapType = .standard
    mapView.isUserInteractionEnabled = interactive
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false

    mapView.delegate = context.coordinator

    // Adding the long press gesture recogniser
    let longPress = UILongPressGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleLongPress(_:))
    )
    // Only adding if the mapView is interactive
    if interactive {
      // Shorter duration
      longPress.minimumPressDuration = 0.35
      mapView.addGestureRecognizer(longPress)
    }

    return mapView
  }

  // I believe this function is called whenever something is updated on the mapView
  func updateUIView(_ mapView: MKMapView, context: Context) {
    print("Updating Map")
    print(isChangingHole)
    // Only change the region and camera if we are changing holes
    if isChangingHole {
      mapView.setRegion(region, animated: false)
      mapView.camera = camera
      let prevAnnotations = mapView.annotations.compactMap {
        $0 as? MKPointAnnotation
      }
      // Removing annotations
      mapView.removeAnnotations(
        prevAnnotations
      )
    }

    mapView.mapType = mapType == .standard ? .standard : .satellite
  }

  // Coordinator for gestures and annotations
  final class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    init(_ parent: MapView) {
      self.parent = parent
    }

    // This function adds annotations with distances to where we tapped on the map
    @MainActor @objc func handleLongPress(_ gr: UILongPressGestureRecognizer) {
      guard gr.state == .began, let mapView = gr.view as? MKMapView else {
        return
      }

      let point = gr.location(in: mapView)
      let coord = mapView.convert(point, toCoordinateFrom: mapView)

      // Creating and adding the annotation
      let annotation = MKPointAnnotation()
      annotation.coordinate = coord

      // Getting the distance and displaying that as the title
      // If we are tracking the user's location
      if parent.viewModel.locationManager.isTrackingLocation {
        if let currentLocation = parent.viewModel.locationManager
          .currentLocation
        {
          let distance = parent.mapManager.distanceBetweenPoints(
            from: coord,
            to: currentLocation.coordinate
          )
          annotation.title = "\(String(format: "%.0f", distance))m"
        }
      } else if let selectedHole = parent.viewModel.selectedHole {
        let distance = parent.mapManager.distanceBetweenPoints(
          from: coord,
          to: CLLocationCoordinate2D(
            latitude: selectedHole.tee_lat,
            longitude: selectedHole.tee_lng
          )
        )
        annotation.title = "\(String(format: "%.0f", distance))m"
      }

      parent.annotations.append(annotation)
      mapView.addAnnotation(annotation)

      // Immediately set it to .ended so we can quickly add others.
      gr.state = .ended
    }

    // Removes annotations on tap
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let annotation = view.annotation as? MKPointAnnotation else {
        return
      }
      mapView.removeAnnotation(annotation)
      parent.annotations.removeAll { $0 == annotation }
    }

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

}
