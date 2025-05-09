//
//  ClubListItem.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//

import SwiftUI

struct ClubListItem: View {

  let club: Club
  
  var body: some View {
    HStack(spacing: 24) {
      VStack(alignment: .leading) {
        Text(club.name)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.content)
        Text("\(club.distance)m")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.content)
      }
      Image(systemName: "ellipsis")
        .font(.system(size: 20, weight: .medium))
        .foregroundStyle(.primaryGreen)
    }
    .padding(8)
    .background(.base200)
    .cornerRadius(12)
    
  }
}

#Preview {
  let testClub = Club(
    name: "7 iron",
    distance: 160
  )
  
  ClubListItem(club: testClub)
}
