//
//  ClubListView.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//

import SwiftData
import SwiftUI

struct ClubListView: View {

  @Query(sort: \Club.distance) private var clubs: [Club]

  @Environment(\.modelContext) private var context
  @State private var showingAddClub = false

  var body: some View {
    // If there's no clubs
    if clubs.count == 0 {
      Text("No clubs added yet.")
        .font(.system(size: 24, weight: .bold))
        .foregroundStyle(.content)
    } else {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(clubs) { club in
            ClubListItem(club: club)
          }
        }
      }
    }
    
  }
}

#Preview {
  ClubListView().modelContainer(for: Club.self)
}
