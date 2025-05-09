//
//  Club.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//
import SwiftData
import Foundation

@Model
final class Club: Identifiable {
  var name: String
  var distance: Int
  
  init(name: String, distance: Int) {
    self.name = name
    self.distance = distance
  }
}
