//
//  ShotAnnotation.swift
//  Greenside
//
//  Created by Oskar Hosken on 15/5/2025.
//

import MapKit
import Foundation

final class ShotAnnotation: NSObject, MKAnnotation {
  let shot: Shot
  
  dynamic var coordinate: CLLocationCoordinate2D
  
  init(shot: Shot) {
    self.shot = shot
    coordinate = CLLocationCoordinate2D(latitude: shot.userLat!, longitude: shot.userLong!)
    
    super.init()
  }
}
