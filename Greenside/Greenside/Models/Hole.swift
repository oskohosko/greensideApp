//
//  Hole.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import Foundation
import CoreLocation

class Hole: Identifiable, Decodable {
  var tee_lat: Double
  var tee_lng: Double
  var green_lat: Double
  var green_lng: Double
  var num: Int
  var par: Int

  var id: Int {
    return num
  }

  init(
    tee_lat: Double,
    tee_lng: Double,
    green_lat: Double,
    green_lng: Double,
    num: Int,
    par: Int
  ) {
    self.num = num
    self.par = par
    self.tee_lat = tee_lat
    self.tee_lng = tee_lng
    self.green_lat = green_lat
    self.green_lng = green_lng
  }

  // Location coordinate of our tee box
  var teeLocation: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: tee_lat,
      longitude: tee_lng
    )
  }

  // Location coordinate of our green
  var greenLocation: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: green_lat,
      longitude: green_lng
    )
  }
}
