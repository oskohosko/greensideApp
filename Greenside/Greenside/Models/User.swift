//
//  User.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

struct User: Codable, Equatable {
  let _id: String
  let firstName: String
  let lastName: String
  let email: String
  let token: String?
}
