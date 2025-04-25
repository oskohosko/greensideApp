//
//  CourseDTO.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

struct CourseDTO: Codable, Identifiable {
  let id: Int
  let name: String
  let lat: Double
  let lng: Double
}
