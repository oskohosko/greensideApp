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

struct DistanceOverlay {
  let line1: MKPolyline
  let distance1: DistanceLabel
  let line2: MKPolyline
  let distance2: DistanceLabel
  let circle: MKCircle
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
    //    longPress.delegate = context.coordinator
    longPress.minimumPressDuration = 0.35
    mapView.addGestureRecognizer(longPress)

    // Adding a pan gesture recogniser for the overlays
    let panGesture = UIPanGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePan(_:))
    )
    panGesture.delegate = context.coordinator
    //    panGesture.cancelsTouchesInView = false
    mapView.addGestureRecognizer(panGesture)

    // Adding a touch gesture for distance annotations
    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleTap(_:))
    )
    tapGesture.delegate = context.coordinator
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

      // Clearing other annotations and overlays
      mapView.removeAnnotations(mapView.annotations)

    }

    // Map interaction settings
    mapView.isZoomEnabled = interactive
    mapView.isScrollEnabled = interactive
    mapView.isPitchEnabled = interactive
    mapView.isRotateEnabled = interactive
    mapView.showsUserLocation = viewModel.locationManager.isTrackingLocation

    // Handling shot overlay
    mapView.removeOverlays(mapView.overlays)
    // And handling distance annotations
    mapView.removeAnnotations(
      mapView.annotations.filter { $0 is DistanceLabel }
    )

    // And removing any annotations that are on the mapview but not in annotations
    let annotationsToRemove = mapView.annotations.filter { annotation in
      !annotations.contains(where: { $0 === annotation })
    }
    mapView.removeAnnotations(annotationsToRemove)

    if let overlay = shotOverlay {
      mapView.addOverlay(overlay, level: .aboveLabels)
    }

    // And handling distance overlay
    if let distanceOverlay = distanceOverlay {
      mapView.addOverlay(distanceOverlay.circle, level: .aboveLabels)
      mapView.addOverlay(distanceOverlay.line1, level: .aboveLabels)
      mapView.addOverlay(distanceOverlay.line2, level: .aboveLabels)
      mapView.addAnnotation(distanceOverlay.distance1)
      mapView.addAnnotation(distanceOverlay.distance2)
    }

    // Handling annotations
    mapView.addAnnotations(annotations)

    // Updating map type
    mapView.mapType = mapType == .standard ? .standard : .satellite
  }

  // Coordinator for gestures and annotations
  final class Coordinator: NSObject, MKMapViewDelegate,
    UIGestureRecognizerDelegate
  {
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
      print("Long press detected")

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
      // Failing if we have tapped in a point annotation
      let tappedAnnotations = mapView.annotations.compactMap {
        annotation -> MKAnnotation? in
        guard let annotationView = mapView.view(for: annotation) else {
          return nil
        }
        return annotationView.frame.contains(gr.location(in: mapView)) ? annotation : nil
      }
      
      if !tappedAnnotations.isEmpty {
        return
      }

      // parent.distanceOverlay = nil

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

      // Getting distance from start to coord and coord to end
      let startToCoord = parent.mapManager.distanceBetweenPoints(
        from: startPoint,
        to: coord
      )
      let coordToEnd = parent.mapManager.distanceBetweenPoints(
        from: coord,
        to: endPoint
      )

      let radius =
        parent.mapManager.distanceBetweenPoints(from: startPoint, to: endPoint)
        * 0.015

      let circle = MKCircle(center: coord, radius: radius)

      // Now I don't want the lines inside the circle, so I need them to stop on the edge of the circle
      // Meaning we need to subtract the radius from the line

      // First bearing is mid point in direction of startpoint
      let firstBearing = parent.mapManager.bearingBetweenPoints(
        from: coord,
        to: startPoint
      )
      let secondBearing = parent.mapManager.bearingBetweenPoints(
        from: coord,
        to: endPoint
      )

      let firstCirclePoint = parent.mapManager.destinationPoint(
        from: coord,
        distance: radius,
        bearing: firstBearing
      )
      let secondCirclePoint = parent.mapManager.destinationPoint(
        from: coord,
        distance: radius,
        bearing: secondBearing
      )

      // Using polylines and circles for the quality
      let line1 = MKPolyline(
        coordinates: [startPoint, firstCirclePoint],
        count: 2
      )
      let line2 = MKPolyline(
        coordinates: [secondCirclePoint, endPoint],
        count: 2
      )

      // Getting distance labels
      let distToPointLabel = DistanceLabel(
        at: line1.coordinate,
        distance: startToCoord
      )
      let distToGreenLabel = DistanceLabel(
        at: line2.coordinate,
        distance: coordToEnd
      )

      let newDistanceOverlay = DistanceOverlay(
        line1: line1,
        distance1: distToPointLabel,
        line2: line2,
        distance2: distToGreenLabel,
        circle: circle
      )

      parent.distanceOverlay = newDistanceOverlay

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

      if let polyline = overlay as? MKPolyline {
        let renderer = MKPolylineRenderer(overlay: polyline)
        renderer.strokeColor = .white
        renderer.lineWidth = 3.0
        renderer.lineCap = .round
        return renderer
      }

      if let circle = overlay as? MKCircle {
        let renderer = MKCircleRenderer(circle: circle)
        renderer.strokeColor = .white
        renderer.lineWidth = 3.0
        return renderer
      }

      return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation)
      -> MKAnnotationView?
    {
      if let label = annotation as? DistanceLabel {
        let view =
          (mapView.dequeueReusableAnnotationView(
            withIdentifier: DistanceLabelView.reuseID
          )
            as? DistanceLabelView)
          ?? DistanceLabelView(
            annotation: label,
            reuseIdentifier: DistanceLabelView.reuseID
          )
        return view
      }
      return nil
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

class DistanceLabel: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  let title: String?

  init(at point: CLLocationCoordinate2D, distance: Double) {
    self.coordinate = point
    self.title = "\(Int(distance))m"
  }
}

class DistanceLabelView: MKAnnotationView {

  static let reuseID = "DistanceLabelView"
  private let label = UILabel()

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configure() {
    canShowCallout = false
    backgroundColor = UIColor.clear

    label.font = .systemFont(ofSize: 12, weight: .medium)
    label.textColor = .black
    label.backgroundColor = .white
    label.textAlignment = .center
    label.layer.cornerRadius = 12
    label.clipsToBounds = true

    addSubview(label)
  }

  override var annotation: MKAnnotation? {
    didSet {
      guard let distanceAnnotation = annotation as? DistanceLabel
      else { return }
      label.text = distanceAnnotation.title
      setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard let text = label.text, !text.isEmpty else { return }

    let hPad: CGFloat = 8
    let vPad: CGFloat = 4

    // Calculate the required size for the text
    let textSize = text.size(withAttributes: [.font: label.font!])
    let labelSize = CGSize(
      width: textSize.width + 2 * hPad,
      height: textSize.height + 2 * vPad
    )

    // Center the label within the annotation view
    label.frame = CGRect(
      x: -labelSize.width / 2,
      y: -labelSize.height / 2,
      width: labelSize.width,
      height: labelSize.height
    )

    // Set the bounds of the annotation view
    bounds = CGRect(
      x: -labelSize.width / 2,
      y: -labelSize.height / 2,
      width: labelSize.width,
      height: labelSize.height
    )
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    label.text = nil
    isHidden = false
  }
}
