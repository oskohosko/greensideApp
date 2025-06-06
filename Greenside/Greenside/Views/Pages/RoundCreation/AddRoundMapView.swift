//
//  AddRoundMapView.swift
//  Greenside
//
//  Created by Oskar Hosken on 30/5/2025.
//

import Foundation
import MapKit
import SwiftUI

// Our MapView from UIKit
struct AddRoundMapView: UIViewRepresentable {
  @EnvironmentObject private var vm: RoundCreationVM

  // Shots initially empty
  @Binding var shots: [Shot]

  private let mapManager = MapManager()
  @Binding var hole: Hole

  var region: MKCoordinateRegion
  var camera: MKMapCamera

  // Coordinator to handle custom annotations
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.setRegion(region, animated: false)
    mapView.camera = camera
    mapView.mapType = .satellite
    mapView.isUserInteractionEnabled = true
    mapView.pointOfInterestFilter = .excludingAll
    mapView.overrideUserInterfaceStyle = .light
    mapView.showsCompass = false

    // Registering shot annotation
    mapView.register(
      ShotAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: ShotAnnotationView.reuseID
    )

    // Adding gesture for adding shots
    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleTap(_:))
    )
    tapGesture.delegate = context.coordinator
    mapView.addGestureRecognizer(tapGesture)

    // Adding shot annotations to the hole if they exist
    mapView.addAnnotations(
      shots.map { shot in
        ShotAnnotation(shot: shot)
      }
    )

    let (newOverlays, distanceLabels) = addCurvedShotAnnotations(shots)
    mapView.addOverlays(newOverlays)
    mapView.addAnnotations(distanceLabels)

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    if vm.isChangingHole {
      mapView.setRegion(region, animated: false)
      mapView.camera = camera

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

      let (newOverlays, distanceLabels) = addCurvedShotAnnotations(shots)
      mapView.addOverlays(newOverlays)
      mapView.addAnnotations(distanceLabels)
    }
    if vm.needsMapRefresh {
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

      let (newOverlays, distanceLabels) = addCurvedShotAnnotations(shots)
      mapView.addOverlays(newOverlays)
      mapView.addAnnotations(distanceLabels)
    }
  }

  // Function that creates a list of the curved shot annotations for each shot
  // It also adds the distance labels
  private func addCurvedShotAnnotations(_ shots: [Shot]) -> (
    overlays: [CurvedShotOverlay], labels: [DistanceLabelAnnotation]
  ) {
    // List of overlays to return
    var overlays: [CurvedShotOverlay] = []
    // List of labels
    var labels: [DistanceLabelAnnotation] = []

    guard shots.count > 1 else {
      return ([], [])
    }

    func createCurve(
      from start: CLLocationCoordinate2D,
      to end: CLLocationCoordinate2D,
      _ currentShot: Shot
    ) {
      let bearing = mapManager.bearingBetweenPoints(
        from: start,
        to: hole.greenLocation
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
      let labelPoint = mapManager.pointOnQuadratic(
        start: start,
        control: controlPoint,
        end: end,
        t: 0.5
      )
      let overlay = CurvedShotOverlay(
        start: start,
        end: end,
        control: controlPoint
      )
      overlays.append(overlay)

      // Labels
      labels.append(
        DistanceLabelAnnotation(
          at: labelPoint,
          distance: distance,
          shot: currentShot
        )
      )
    }

    // Adding the curves to each shot
    for idx in 0..<(shots.count - 1) {
      createCurve(
        from: shots[idx].location,
        to: shots[idx + 1].location,
        shots[idx]
      )
    }

    return (overlays, labels)
  }

  // Coordinator handling annotations
  final class Coordinator: NSObject, MKMapViewDelegate,
    UIGestureRecognizerDelegate
  {
    var parent: AddRoundMapView

    init(_ parent: AddRoundMapView) {
      self.parent = parent
    }

    // Handles when the user taps on the mapview
    @MainActor @objc func handleTap(_ gr: UITapGestureRecognizer) {
      guard let mapView = gr.view as? MKMapView
      else {
        return
      }

      // Another guard for number of shotannotations
      guard
        mapView.annotations.map({ $0 is ShotAnnotation }).filter({ $0 }).count
          < 10
      else {
        return
      }

      // Small haptic feedback
      let feedback = UIImpactFeedbackGenerator(style: .light)
      feedback.prepare()
      feedback.impactOccurred()

      // Getting point where user tapped
      let point = gr.location(in: mapView)
      let coord = mapView.convert(point, toCoordinateFrom: mapView)

      // Getting distance to the pin
      let currentHole = parent.hole

      let distance = parent.mapManager.distanceBetweenPoints(
        from: coord,
        to: currentHole.greenLocation
      )
      
      print(distance)

      // Creating a new shot
      let shot = Shot(
        distanceToPin: Int(distance),
        time: Date().timeIntervalSince1970,
        userLat: coord.latitude,
        userLong: coord.longitude
      )

      // Creating an annotation from the shot
      let annotation = ShotAnnotation(shot: shot)

      parent.shots.append(shot)
      mapView.addAnnotation(annotation)

      // Adding a curveshot overlay between them
      let (newOverlays, distanceLabels) = parent.addCurvedShotAnnotations(
        parent.shots
      )
      mapView.addOverlays(newOverlays)
      mapView.addAnnotations(distanceLabels)

      gr.state = .ended
    }

    func gestureRecognizer(
      _ g: UIGestureRecognizer,
      shouldReceive touch: UITouch
    ) -> Bool {

      // Only add taps when they aren't on an annotationView
      var view: UIView? = touch.view
      while let v = view {
        if v is MKAnnotationView {
          return false
        }
        view = v.superview
      }
      return true
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
      if let shot = annotation as? ShotAnnotation {
        let view =
          (mapView.dequeueReusableAnnotationView(
            withIdentifier: ShotAnnotationView.reuseID
          )
            as? ShotAnnotationView)
          ?? ShotAnnotationView(
            annotation: shot,
            reuseIdentifier: ShotAnnotationView.reuseID
          )
        view.size = 16

        return view
      }

      if let label = annotation as? DistanceLabelAnnotation {
        let view =
          (mapView.dequeueReusableAnnotationView(
            withIdentifier: DistanceAnnotationView.reuseID
          )
            as? DistanceAnnotationView)
          ?? DistanceAnnotationView(
            annotation: label,
            reuseIdentifier: DistanceAnnotationView.reuseID
          )
        return view
      }
      return nil
    }

    // Helper for annotations
    private func metersPerPixel(_ mapView: MKMapView) -> Double {
      let rect = mapView.visibleMapRect
      return rect.size.width / Double(mapView.bounds.width)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      updateDistanceLabelsVisibility(mapView)
    }

    private func updateDistanceLabelsVisibility(_ mapView: MKMapView) {
      let metersPerPixel = metersPerPixel(mapView)
      let hideThreshold = 4.0

      // Simply iterating through all current annotations and show/hide them
      for annotation in mapView.annotations {
        if let distanceLabel = annotation as? DistanceLabelAnnotation,
          let annotationView = mapView.view(for: distanceLabel)
        {

          let shouldShow =
            !distanceLabel.hidesWhenZoomedOut || metersPerPixel <= hideThreshold
          annotationView.isHidden = !shouldShow
        }
      }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let tapped = view.annotation as? ShotAnnotation else { return }

      // Index of tapped shot
      guard
        let i = parent.shots.firstIndex(where: {
          $0.userLat == tapped.shot.userLat
            && $0.userLong == tapped.shot.userLong
        })
      else {
        return
      }
      // Remove everything if i == 0
      if i == 0 {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        parent.shots.removeAll()
        return
      }
      
      // Getting remaining shots and updating shots array
      let remaining = Array(parent.shots.prefix(i))
      parent.shots = remaining

      // Now removing all annotations past this shot
      mapView.annotations
        .compactMap { $0 as? ShotAnnotation }
        .filter { shotAnnot in
          !remaining.contains(where: {
            $0.userLat == shotAnnot.shot.userLat
              && $0.userLong == shotAnnot.shot.userLong
          })
        }
        .forEach { mapView.removeAnnotation($0) }
      
      // Removing all overlays past and including this shot
      let badOverlays = mapView.overlays.compactMap { $0 as? CurvedShotOverlay }
        .suffix(from: i - 1)
      mapView.removeOverlays(Array(badOverlays))
      // Removing all annotations past and including this shot
      let badLabels = mapView.annotations
        .compactMap { $0 as? DistanceLabelAnnotation }
        .suffix(from: i - 1)
      mapView.removeAnnotations(Array(badLabels))
      
      print(parent.shots)
    }
  }
}
