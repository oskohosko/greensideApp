//
//  DistanceOverlay.swift
//  Greenside
//
//  Created by Oskar Hosken on 6/6/2025.
//

import Foundation
import MapKit

class DistanceOverlay: NSObject, MKOverlay {

  private(set) var startCoordinate: CLLocationCoordinate2D
  private(set) var midCoordinate: CLLocationCoordinate2D
  private(set) var endCoordinate: CLLocationCoordinate2D

  private let mapManager = MapManager()

  // MARK: - Required MKOverlay attributes
  var coordinate: CLLocationCoordinate2D {
    return midCoordinate
  }

  var boundingMapRect: MKMapRect {
    return MKMapRect.world
  }
  // Constructor
  init(
    startCoordinate: CLLocationCoordinate2D,
    midCoordinate: CLLocationCoordinate2D,
    endCoordinate: CLLocationCoordinate2D
  ) {
    self.startCoordinate = startCoordinate
    self.midCoordinate = midCoordinate
    self.endCoordinate = endCoordinate
  }

  // This will be called when a user taps a new place or drags this annotation
  func update(midCoordinate newMidCoordinate: CLLocationCoordinate2D) {
    // Start location and end location stay fixed
    self.midCoordinate = newMidCoordinate
  }
}

// Now the renderer

class DistanceOverlayRenderer: MKOverlayRenderer {
  private var distanceOverlay: DistanceOverlay? {
    return overlay as? DistanceOverlay
  }

  override func draw(
    _ mapRect: MKMapRect,
    zoomScale: MKZoomScale,
    in context: CGContext
  ) {
    guard let overlay = distanceOverlay else {
      return
    }
    
    let startPoint = point(for: MKMapPoint(overlay.startCoordinate))
    let midPoint = point(for: MKMapPoint(overlay.midCoordinate))
    let endPoint = point(for: MKMapPoint(overlay.endCoordinate))
    
    // Setting up drawing appearance
    context.setStrokeColor(UIColor.white.cgColor)
    context.setLineWidth(6.0 / sqrt(zoomScale))
    context.setShouldAntialias(true)
    context.setAllowsAntialiasing(true)
    context.interpolationQuality = .high
    context.setLineCap(.round)
    context.setFlatness(0.01)
    context.setBlendMode(.normal)
    
    // Drawing lines from start to mid and mid to end
    context.beginPath()
    context.move(to: startPoint)
    context.addLine(to: midPoint)
    context.strokePath()
    
    context.move(to: midPoint)
    context.addLine(to: endPoint)
    context.strokePath()
  }
}
