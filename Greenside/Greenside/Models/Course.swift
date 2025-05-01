//
//  Course.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import Foundation
import CoreLocation

class Course: Identifiable, Decodable {
  var id: Int
  var name: String
  var lat: Double
  var lng: Double

  init(id: Int, name: String, lat: Double, lng: Double) {
    self.id = id
    self.name = name
    self.lat = lat
    self.lng = lng
  }

  var locationCoordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: lat,
      longitude: lng
    )
  }
}
