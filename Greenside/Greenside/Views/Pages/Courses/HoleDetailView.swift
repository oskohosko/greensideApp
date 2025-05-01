//
//  HoleDetailView.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import SwiftUI

struct HoleDetailView: View {
  let hole: Hole

  var body: some View {
    Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
  }
}

#Preview {
  let testHole = Hole(
    tee_lat: -37.840217196015125,
    tee_lng: 145.09999076907312,
    green_lat: -37.8384012989252,
    green_lng: 145.100180946968,
    num: 6,
    par: 4
  )
  HoleDetailView(hole: testHole)
}
