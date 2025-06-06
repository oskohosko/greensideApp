//
//  MapView.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import Foundation
import MapKit
import SwiftUI

// Enum for the different layers in our map
enum MapLayerType: Int {
  case base = 0  // Base map layer
  case staticMap = 1  // Static annotations/overlays
  case interactive = 2  // Interactive elements being manipulated
}

// Our MapView from UIKit
struct CourseMapView: UIViewRepresentable {
  @EnvironmentObject private var viewModel: CoursesViewModel
  private let mapManager = MapManager()

  @Binding var annotations: [MKPointAnnotation]
  @Binding var shotOverlay: ShotOverlay?
  @Binding var distanceOverlay: DistanceOverlay?
  
  // Property to store our custom shot overlay
  @State private var activeShotOverlay: ShotOverlay?

  var region: MKCoordinateRegion
  var camera: MKMapCamera
  let isMapInteractionEnabled: Bool
  let mapType: MapType
  var isChangingHole: Bool

  @Binding var interactive: Bool

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
    mapView.mapType = .standard
    mapView.isUserInteractionEnabled = isMapInteractionEnabled
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false

    // Setting up delegate
    mapView.delegate = context.coordinator

    // Adding the long press gesture recogniser
    let longPress = UILongPressGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleLongPress(_:))
    )
    longPress.minimumPressDuration = 0.35
    mapView.addGestureRecognizer(longPress)

    // Adding a pan gesture recogniser for the overlays
    let panGesture = UIPanGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePan(_:))
    )
    mapView.addGestureRecognizer(panGesture)

    // Adding a touch gesture for distance annotations
    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleTap(_:))
    )
    mapView.addGestureRecognizer(tapGesture)

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    // Only change the region and camera if we are changing holes
    if isChangingHole {
      mapView.setRegion(region, animated: false)
      mapView.camera = camera

      // Clear active shot overlay when changing holes
      context.coordinator.activeOverlay = nil
    }

    // Map interaction settings
    mapView.isZoomEnabled = interactive
    mapView.isScrollEnabled = interactive
    mapView.isPitchEnabled = interactive
    mapView.isRotateEnabled = interactive
    mapView.showsUserLocation = viewModel.locationManager.isTrackingLocation

    // Handling shot overlay
    mapView.removeOverlays(mapView.overlays)
    if let overlay = shotOverlay {
      mapView.addOverlay(overlay, level: .aboveLabels)
    }
    // And handling distance overlay
    if let distanceOverlay = distanceOverlay {
      mapView.addOverlay(distanceOverlay, level: .aboveLabels)
    }

    // Handling annotations
    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotations(annotations)
    
    
    // Updating map type
    mapView.mapType = mapType == .standard ? .standard : .satellite
  }

  // Coordinator for gestures and annotations
  final class Coordinator: NSObject, MKMapViewDelegate {
    var parent: CourseMapView

    // Active overlay being manipulated
    var activeOverlay: ShotOverlay?
    var isDraggingCircle: Bool = false

    init(_ parent: CourseMapView) {
      self.parent = parent
    }

    // MARK: - Gesture Recognizer Handlers

    // Long press handler for annotations
    @MainActor @objc func handleLongPress(_ gr: UILongPressGestureRecognizer) {
      guard gr.state == .began, let mapView = gr.view as? MKMapView else {
        return
      }

      let point = gr.location(in: mapView)
      let coord = mapView.convert(point, toCoordinateFrom: mapView)

      // Creating and adding annotation
      let annotation = MKPointAnnotation()
      annotation.coordinate = coord

      // Calculating distance and displaying as title
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

      // Set to .ended to allow for quick consecutive additions
      gr.state = .ended
    }

    // Optimized pan handler for drag operations
    @MainActor @objc func handlePan(_ gr: UIPanGestureRecognizer) {
      guard let mapView = gr.view as? MKMapView else {
        return
      }

      let point = gr.location(in: mapView)
      let dragCoord = mapView.convert(point, toCoordinateFrom: mapView)

      switch gr.state {
      case .began:
        if activeOverlay == nil,
          let shot = parent.shotOverlay,
          let renderer = mapView.renderer(for: shot) as? ShotOverlayRenderer
        {
          let mapPoint = MKMapPoint(dragCoord)
          isDraggingCircle = renderer.isPointInCircle(mapPoint)

          if isDraggingCircle {
            activeOverlay = shot
          }
        } else if let overlay = activeOverlay,
          let renderer = mapView.renderer(for: overlay) as? ShotOverlayRenderer
        {
          // If we already have an active overlay, check if user is touching the circle
          let mapPoint = MKMapPoint(dragCoord)
          isDraggingCircle = renderer.isPointInCircle(mapPoint)
        }

      case .changed where isDraggingCircle && activeOverlay != nil:
        guard let overlay = activeOverlay else { return }

        // Calculating new bearing based on start point and drag location
        let newBearing = parent.mapManager.bearingBetweenPoints(
          from: overlay.startCoordinate,
          to: dragCoord
        )

        // Calculating distance of the original line to maintain
        let originalDistance = parent.mapManager.distanceBetweenPoints(
          from: overlay.startCoordinate,
          to: overlay.endCoordinate
        )

        // Calculating new end point with same distance but new bearing
        let newEndPoint = parent.mapManager.destinationPoint(
          from: overlay.startCoordinate,
          distance: originalDistance,
          bearing: newBearing
        )

        // Updating the bounding rect so the overlay doesn't get clipped
        guard
          let renderer = mapView.renderer(for: overlay) as? ShotOverlayRenderer
        else {
          return
        }
        // Old one
        let oldBoundingRect = overlay.boundingMapRect

        // Updating
        overlay.update(endCoordinate: newEndPoint)
        let newBoundingRect = oldBoundingRect.union(overlay.boundingMapRect)
        renderer.setNeedsDisplay(newBoundingRect)

      case .ended, .cancelled, .failed:
        if isDraggingCircle,
          let overlay = activeOverlay,
          let renderer = mapView.renderer(for: overlay)
        {
          renderer.setNeedsDisplay()
        }
        activeOverlay = nil
        isDraggingCircle = false

      default:
        break
      }
    }

    // Tap Gesture recogniser method
    @MainActor @objc func handleTap(_ gr: UITapGestureRecognizer) {
      guard let mapView = gr.view as? MKMapView else {
        return
      }

      // Adding a little haptic feedback
      let feedback = UIImpactFeedbackGenerator(style: .light)
      feedback.prepare()
      feedback.impactOccurred()

      // Fetching the point in which the user tapped
      let point = gr.location(in: mapView)
      let coord = mapView.convert(point, toCoordinateFrom: mapView)

      // Getting end point and start point
      // if we are trakcing location we want to use the user's position
      var startPoint: CLLocationCoordinate2D = .init()
      if parent.viewModel.locationManager.isTrackingLocation {
        if let currentLocation = parent.viewModel.locationManager
          .currentLocation
        {
          // Setting start as user's location
          startPoint = currentLocation.coordinate
        }
        // Otherwise we are using the tee
      } else {
        if let selectedHole = parent.viewModel.selectedHole {
          
          startPoint = selectedHole.teeLocation
        }
      }
      // Now end point is the green location
      let endPoint = parent.viewModel.selectedHole?.greenLocation ?? coord
      
      // Now we should have three points and we need to connect them
      let distanceOverlay = DistanceOverlay(
        startCoordinate: startPoint,
        midCoordinate: coord,
        endCoordinate: endPoint)
      parent.distanceOverlay = distanceOverlay
    }

    // MARK: - MKMapViewDelegate Methods

    // Render overlays based on their type
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
      -> MKOverlayRenderer
    {
      // Handle our custom ShotOverlay
      if let shotOverlay = overlay as? ShotOverlay {
        return ShotOverlayRenderer(overlay: shotOverlay)
      }
      
      // Handling custom distanceOverlay
      if let distanceOverlay = overlay as? DistanceOverlay {
        return DistanceOverlayRenderer(overlay: distanceOverlay)
      }

      // Handle standard overlays
      switch overlay {
      case is MKPolyline:
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .white
        renderer.lineWidth = 3
        return renderer

      case is MKCircle:
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.strokeColor = .white
        renderer.lineWidth = 3
        return renderer

      default:
        return MKOverlayRenderer()
      }
    }

    // Handle annotation selection
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let annotation = view.annotation as? MKPointAnnotation else {
        return
      }
      mapView.removeAnnotation(annotation)
      parent.annotations.removeAll { $0 == annotation }
    }
  }
}
