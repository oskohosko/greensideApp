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

  let hole: Hole
  // The shots that we made on this hole
  @Binding var shots: [Shot]

  var region: MKCoordinateRegion
  var camera: MKMapCamera
  let mapType: MapType
  let annotationSize: Int
  let interactive: Bool
  var isChangingHole: Bool

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
    mapView.isUserInteractionEnabled = interactive
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false

    // Registering shot annotation
    mapView.register(
      ShotAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: ShotAnnotationView.reuseID
    )

    // Adding annotations for each shot onto the map
    mapView.addAnnotations(
      shots.map { shot in
        ShotAnnotation(shot: shot)
      }
    )

    // Adding curved overlays between each consecutive shot
    if shots.count > 1 && interactive {

      for idx in 0..<(shots.count - 1) {
        let bearing = mapManager.bearingBetweenPoints(
          from: shots[idx].location,
          to: hole.greenLocation
        )

        let start = shots[idx].location
        let end = shots[idx + 1].location
        let distance = mapManager.distanceBetweenPoints(
          from: start,
          to: end
        )
        let controlPoint = mapManager.controlPoint(
          from: start,
          to: end,
          initialBearing: bearing,
          curveOffsetMeters: distance * 0.15
        )
        let overlay = CurvedShotOverlay(
          start: start,
          end: end,
          control: controlPoint
        )
        mapView.addOverlay(overlay)
      }
      // And finally adding the last shot
      if let lastShot = shots.last {
        let start = lastShot.location
        let end = hole.greenLocation
        let bearing = mapManager.bearingBetweenPoints(
          from: start,
          to: end
        )
        let distance = mapManager.distanceBetweenPoints(
          from: start,
          to: end
        )
        let controlPoint = mapManager.controlPoint(
          from: start,
          to: end,
          initialBearing: bearing,
          curveOffsetMeters: distance * 0.15
        )

        let overlay = CurvedShotOverlay(
          start: start,
          end: end,
          control: controlPoint
        )
        mapView.addOverlay(overlay)
      }
    }

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    if isChangingHole {
      // Removing previouse annotations
      mapView.removeAnnotations(mapView.annotations)

      // Adding new ones
      mapView.addAnnotations(
        shots.map { shot in
          ShotAnnotation(shot: shot)
        }
      )

      // Also removing existing overlays
      mapView.removeOverlays(mapView.overlays)

      // And adding new ones
      if shots.count > 1 && interactive {

        for idx in 0..<(shots.count - 1) {
          
          let bearing = mapManager.bearingBetweenPoints(
            from: shots[idx].location,
            to: hole.greenLocation
          )

          let start = shots[idx].location
          let end = shots[idx + 1].location
          let distance = mapManager.distanceBetweenPoints(
            from: start,
            to: end
          )
          let controlPoint = mapManager.controlPoint(
            from: start,
            to: end,
            initialBearing: bearing,
            curveOffsetMeters: distance * 0.15
          )
          let overlay = CurvedShotOverlay(
            start: start,
            end: end,
            control: controlPoint
          )
          mapView.addOverlay(overlay)
        }
        // And finally adding the last shot
        if let lastShot = shots.last {
          let start = lastShot.location
          let end = hole.greenLocation
          let bearing = mapManager.bearingBetweenPoints(
            from: start,
            to: end
          )
          let distance = mapManager.distanceBetweenPoints(
            from: start,
            to: end
          )
          let controlPoint = mapManager.controlPoint(
            from: start,
            to: end,
            initialBearing: bearing,
            curveOffsetMeters: distance * 0.15
          )
          let overlay = CurvedShotOverlay(
            start: start,
            end: end,
            control: controlPoint
          )
          mapView.addOverlay(overlay)
        }
      }
      mapView.setRegion(region, animated: false)
      mapView.camera = camera
      
    }
    
    // Updating map type
    mapView.mapType = mapType == .standard ? .standard : .satellite
  }

  final class Coordinator: NSObject, MKMapViewDelegate {
    var parent: RoundMapView

    init(_ parent: RoundMapView) {
      self.parent = parent
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay)
      -> MKOverlayRenderer
    {
      if let curvedOverlay = overlay as? CurvedShotOverlay {
        let renderer = CurvedLineRenderer(overlay: curvedOverlay)
        renderer.strokeColor = .blue400
        renderer.lineWidth = 2
        renderer.lineCap = .round
        return renderer
      }
      return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
      -> MKAnnotationView?
    {
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
          reuseIdentifier: ShotAnnotationView.reuseID,
        )

      } else {
        annotationView?.annotation = shotAnnotation
      }

      annotationView?.size = parent.annotationSize

      return annotationView
    }
  }
}

class CurvedShotOverlay: NSObject, MKOverlay {
  let coordinate: CLLocationCoordinate2D
  let boundingMapRect: MKMapRect
  let start: CLLocationCoordinate2D
  let end: CLLocationCoordinate2D
  let controlPoint: CLLocationCoordinate2D

  init(
    start: CLLocationCoordinate2D,
    end: CLLocationCoordinate2D,
    control: CLLocationCoordinate2D
  ) {
    self.start = start
    self.end = end
    self.controlPoint = control

    // Calculating center and bounding rect for overlay protocol
    self.coordinate = CLLocationCoordinate2D(
      latitude: (start.latitude + end.latitude) / 2,
      longitude: (start.longitude + end.longitude) / 2
    )

    let point1 = MKMapPoint(start)
    let point2 = MKMapPoint(end)

    self.boundingMapRect = MKMapRect(
      x: min(point1.x, point2.x),
      y: min(point1.y, point2.y),
      width: abs(point1.x - point2.x),
      height: abs(point1.y - point2.y)
    )
  }
}

class CurvedLineRenderer: MKOverlayPathRenderer {
  override func createPath() {
    guard let overlay = overlay as? CurvedShotOverlay else {
      return
    }
    let path = UIBezierPath()
    let startPoint = point(for: MKMapPoint(overlay.start))
    let endPoint = point(for: MKMapPoint(overlay.end))
    let controlPoint = point(for: MKMapPoint(overlay.controlPoint))
    path.move(to: startPoint)
    path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
    self.path = path.cgPath
  }
}
