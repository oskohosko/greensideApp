//
//  UserDTO.swift
//  Greenside
//
//  Created by Oskar Hosken on 25/4/2025.
//

struct UserDTO: Codable {
  let _id: String
  let firstName: String
  let lastName: String
  let email: String
  let token: String?
}
