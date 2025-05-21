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

  func degreesToRadians(_ degrees: Double) -> Double {
    return degrees * .pi / 180.0
  }

  func radiansToDegrees(_ radians: Double) -> Double {
    return radians * 180.0 / .pi
  }

  // Function that returns an end point based on a start point, distance and bearing
  func destinationPoint(
    from: CLLocationCoordinate2D,
    distance: Double,
    bearing: Double
  ) -> CLLocationCoordinate2D {
    // Converting distance and bearing to radians
    let currentLatitude = degreesToRadians(from.latitude)
    let currentLongitude = degreesToRadians(from.longitude)
    let bearingRadians = degreesToRadians(bearing)

    // Earth's radius in meters
    let radius = 6371e3
    let newLatitude = asin(
      sin(currentLatitude) * cos(distance / radius) + cos(currentLatitude)
        * sin(distance / radius) * cos(bearingRadians)
    )
    let newLongitude =
      currentLongitude
      + atan2(
        sin(bearingRadians) * sin(distance / radius) * cos(currentLatitude),
        cos(distance / radius) - sin(currentLatitude) * sin(newLatitude)
      )
    // Converting back to degrees
    let finalLatitude = radiansToDegrees(newLatitude)
    let finalLongitude = radiansToDegrees(newLongitude)
    return CLLocationCoordinate2D(
      latitude: finalLatitude,
      longitude: finalLongitude
    )
  }

  func controlPoint(
    from start: CLLocationCoordinate2D,
    to end: CLLocationCoordinate2D,
    initialBearing: Double,
    curveOffsetMeters: CLLocationDistance = 20
  ) -> CLLocationCoordinate2D {
    let midLat = (start.latitude + end.latitude) / 2
    let midLon = (start.longitude + end.longitude) / 2
    let mid = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)

    let bearingToEnd = bearingBetweenPoints(from: start, to: end)

    let angle =
      (bearingToEnd - initialBearing + 540).truncatingRemainder(dividingBy: 360)
      - 180

    let sideOffset = angle > 0 ? -90.0 : 90.0
    let perpendicularBearing = (initialBearing + sideOffset)
      .truncatingRemainder(dividingBy: 360)
    return destinationPoint(
      from: mid,
      distance: curveOffsetMeters,
      bearing: perpendicularBearing
    )
  }

}
