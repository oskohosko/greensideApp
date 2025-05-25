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
  @EnvironmentObject private var sheetPosition: SheetPositionHandler

  private let mapManager = MapManager()

  let hole: Hole
  // The shots that we made on this hole
  @Binding var shots: [Shot]

  var region: MKCoordinateRegion
  var camera: MKMapCamera
  @Binding var mapType: MapType
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

    let (newOverlays, distanceLabels) = addCurvedShotAnnotations(shots)
    mapView.addOverlays(newOverlays)
    mapView.addAnnotations(distanceLabels)

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

      let (newOverlays, distanceLabels) = addCurvedShotAnnotations(shots)
      mapView.addOverlays(newOverlays)
      mapView.addAnnotations(distanceLabels)

      mapView.setRegion(region, animated: false)
      mapView.camera = camera
    }

    // Updating map type
    mapView.mapType = mapType == .standard ? .standard : .satellite
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

    guard shots.count > 0, interactive else {
      return ([], [])
    }

    func createCurve(
      from start: CLLocationCoordinate2D,
      to end: CLLocationCoordinate2D
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
        DistanceLabelAnnotation(at: labelPoint, distance: distance)
      )
    }

    // Adding the curves to each shot
    for idx in 0..<(shots.count - 1) {
      createCurve(from: shots[idx].location, to: shots[idx + 1].location)
    }
    // And final shot
    if let last = shots.last {
      createCurve(from: last.location, to: hole.greenLocation)
    }

    return (overlays, labels)
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
        view.size = parent.annotationSize

        view.onTap = { [weak self] in
          guard let self else {
            return
          }
          withAnimation(.easeInOut(duration: 0.16)) {
            self.parent.sheetPosition.position = .third
          }

        }

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
        
        view.onTap = { [weak self] in
          guard let self else {
            return
          }
          withAnimation(.easeInOut(duration: 0.16)) {
            self.parent.sheetPosition.position = .third
          }

        }
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

    // For when a user selects our annotation
    //        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    //
    //          switch view.annotation {
    //          case is ShotAnnotation, is DistanceLabelAnnotation:
    //
    //            DispatchQueue.main.async {
    //              withAnimation(.easeInOut(duration: 0.18)) {
    //                self.parent.sheetPosition.position = .third
    //              }
    //    //          self.parent.isSheetPresented = true
    //            }
    //
    //          default: break
    //          }
    //
    //          mapView.deselectAnnotation(view.annotation, animated: false)
    //        }
  }
}

// This is our curved line
class CurvedShotOverlay: NSObject, MKOverlay {
  let coordinate: CLLocationCoordinate2D
  let boundingMapRect: MKMapRect
  let start: CLLocationCoordinate2D
  let end: CLLocationCoordinate2D
  let controlPoint: CLLocationCoordinate2D
  let distance: Double

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

    // Calculating distance of the shot
    let loc1 = CLLocation(latitude: start.latitude, longitude: start.longitude)
    let loc2 = CLLocation(latitude: end.latitude, longitude: end.longitude)
    self.distance = loc1.distance(from: loc2)

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

class DistanceLabelAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  let title: String?
  let hidesWhenZoomedOut: Bool

  init(at point: CLLocationCoordinate2D, distance: Double) {
    self.coordinate = point
    self.title = "\(Int(distance))m"
    self.hidesWhenZoomedOut = distance < 30
  }
}

class DistanceAnnotationView: MKAnnotationView {

  static let reuseID = "DistanceAnnotationView"
  private let label = UILabel()
  var onTap: (() -> Void)?

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
      guard let distanceAnnotation = annotation as? DistanceLabelAnnotation
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
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    onTap?()
    
    super.touchesBegan(touches, with: event)
  }
}
