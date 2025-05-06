//
//  MapManager.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import Foundation
import MapKit

class MapManager {

  // This function takes the tee and green and fits them into a region
  // It also rotates the region such that the tee is always at the bottom
  func fitRegion(tee: CLLocationCoordinate2D, green: CLLocationCoordinate2D)
    -> MKCoordinateRegion
  {
    // We firstly need to get the center coordinate
    let center = CLLocationCoordinate2D(
      latitude: (tee.latitude + green.latitude) / 2,
      longitude: (tee.longitude + green.longitude) / 2
    )
    // This is a base zoom factor, with smaller values being more zoomed in.
    // We want zoomed in
    let baseZoomFactor = 0.0005

    // Getting the distance of the hole and calculating another zoom factor
    // This means we can fit the hole in well
    let holeDistance = distanceBetweenPoints(from: tee, to: green)

    // Trial and error values (tiny bit off for par 3s with large greens)
    let zoomFactor = max(
      baseZoomFactor,
      min(0.003, baseZoomFactor * holeDistance / 100.0)
    )

    // And now calculating the span based on the final zoom factor
    let span = MKCoordinateSpan(
      latitudeDelta: zoomFactor,
      longitudeDelta: zoomFactor
    )

    // And now returning the region
    return MKCoordinateRegion(center: center, span: span)
  }

  func setCamera(tee: CLLocationCoordinate2D, green: CLLocationCoordinate2D)
    -> MKMapCamera
  {
    // We firstly need to get the center coordinate
    let center = CLLocationCoordinate2D(
      latitude: (tee.latitude + green.latitude) / 2,
      longitude: (tee.longitude + green.longitude) / 2
    )
    // This bearing allows us to rotate the region to fit tee at bottom and green at top
    let bearing = bearingBetweenPoints(from: tee, to: green)

    // Getting the distance of the hole and calculating another zoom factor
    // This means we can fit the hole in well
    let holeDistance = distanceBetweenPoints(from: tee, to: green)

    // Returning the camera
    return MKMapCamera(
      lookingAtCenter: center,
      fromDistance: min(1100, holeDistance * 2.7),
      pitch: 0,
      heading: bearing
    )
  }

  // Function that calculates the bearing between two locations
  func bearingBetweenPoints(
    from: CLLocationCoordinate2D,
    to: CLLocationCoordinate2D
  ) -> Double {
    // Getting radians of each coordinate
    let lat1 = from.latitude * .pi / 180
    let lon1 = from.longitude * .pi / 180
    let lat2 = to.latitude * .pi / 180
    let lon2 = to.longitude * .pi / 180

    // Distance longitude
    let distLon = lon2 - lon1

    // Getting the bearing using arctan
    let y = sin(distLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(distLon)
    let bearing = atan2(y, x)

    // Returning bearing in degrees.
    return bearing * 180 / .pi
  }

  // Function that calculates the distance between two locations
  func distanceBetweenPoints(
    from: CLLocationCoordinate2D,
    to: CLLocationCoordinate2D
  ) -> Double {
    // Changing locations to CLLocation to use .distance(from:) method.
    let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)

    return loc1.distance(from: loc2)
  }
}
