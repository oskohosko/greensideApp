//
//  CourseData.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import Foundation

class CourseData: Identifiable, Decodable {
  var name: String
  var state: String
  var par: Int
  var lat: Double
  var lng: Double
  var holes: [Hole]
}
