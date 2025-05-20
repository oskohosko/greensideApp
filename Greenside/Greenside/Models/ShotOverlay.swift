//
//  ShotOverlay.swift
//  Greenside
//
//  Created by Oskar Hosken on 13/5/2025.
//

import Foundation
import MapKit

class ShotOverlay: NSObject, MKOverlay {
  private(set) var startCoordinate: CLLocationCoordinate2D
  private(set) var endCoordinate: CLLocationCoordinate2D

  // Store the fixed shot distance in meters
  private(set) var shotDistance: CLLocationDistance

  private(set) var dispersionFactor: Double = 0.1

  private let mapManager = MapManager()

  var dispersionRadius: CLLocationDistance {
    return shotDistance * dispersionFactor
  }

  var midCoordinate: CLLocationCoordinate2D {
    let midLat = (startCoordinate.latitude + endCoordinate.latitude) / 2
    let midLng = (startCoordinate.longitude + endCoordinate.longitude) / 2
    return CLLocationCoordinate2D(latitude: midLat, longitude: midLng)
  }

  // This is required from MKOverlay
  var coordinate: CLLocationCoordinate2D {
    return midCoordinate
  }

  // This is required from MKOverlay
  var boundingMapRect: MKMapRect {

    MKMapRect.world
  }

  init(
    startCoordinate: CLLocationCoordinate2D,
    endCoordinate: CLLocationCoordinate2D,
    shotDistance: CLLocationDistance
  ) {
    self.startCoordinate = startCoordinate
    self.endCoordinate = endCoordinate
    self.shotDistance = shotDistance
    super.init()
  }

  // Updates end coordinate while maintaining the fixed club distance
  func update(endCoordinate newEndCoordinate: CLLocationCoordinate2D) {
    // Calculating the bearing to the new end coordinate
    let bearing = mapManager.bearingBetweenPoints(
      from: startCoordinate,
      to: newEndCoordinate
    )

    // Setting the end coordinate using the fixed shot distance and new bearing
    self.endCoordinate = mapManager.destinationPoint(
      from: startCoordinate,
      distance: shotDistance,
      bearing: bearing
    )
  }
}

class ShotOverlayRenderer: MKOverlayRenderer {
  private var shotOverlay: ShotOverlay? {
    return overlay as? ShotOverlay
  }

  override func draw(
    _ mapRect: MKMapRect,
    zoomScale: MKZoomScale,
    in context: CGContext
  ) {
    guard let shot = shotOverlay else { return }

    // Set up drawing appearance
    context.setStrokeColor(UIColor.white.cgColor)
    context.setLineWidth(6.0 / sqrt(zoomScale))
    context.setShouldAntialias(true)
    context.setAllowsAntialiasing(true)
    context.interpolationQuality = .high
    context.setLineCap(.round)

    context.setFlatness(0.01)
    context.setBlendMode(.normal)

    // Draw the line
    let startPoint = point(for: MKMapPoint(shot.startCoordinate))
    let endPoint = point(for: MKMapPoint(shot.endCoordinate))

    context.beginPath()
    context.move(to: startPoint)
    context.addLine(to: endPoint)
    context.strokePath()

    // Draw the dispersion circle
    let endMapPoint = MKMapPoint(shot.endCoordinate)
    let circlePoint = point(for: endMapPoint)

    // Converting meters to points based on the zoom scale and latitude
    let radiusInPoints =
      MKMapPointsPerMeterAtLatitude(shot.endCoordinate.latitude)
      * shot.dispersionRadius

    context.addEllipse(
      in: CGRect(
        x: circlePoint.x - radiusInPoints,
        y: circlePoint.y - radiusInPoints,
        width: radiusInPoints * 2,
        height: radiusInPoints * 2
      )
    )
    context.strokePath()
  }

  func isPointInCircle(_ mapPoint: MKMapPoint) -> Bool {
    guard let shot = shotOverlay else { return false }

    let endMapPoint = MKMapPoint(shot.endCoordinate)
    let distance = endMapPoint.distance(to: mapPoint)

    // Converting circle radius from meters to map points
    let radiusInMapPoints =
      shot.dispersionRadius
      * MKMapPointsPerMeterAtLatitude(shot.endCoordinate.latitude)

    return distance <= radiusInMapPoints
  }
}
