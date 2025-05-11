//
//  ClubListItem.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//

import SwiftUI

struct ClubListItem: View {

  let club: Club
  
  @Environment(\.modelContext) private var context
  
  @Binding var clubToEdit: Club?
  
  var body: some View {
    HStack {
      Text(club.name)
        .font(.system(size: 18, weight: .bold))
        .foregroundStyle(.content)
      Spacer()
      Text("\(club.distance)m")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(.content)
      Button {
        clubToEdit = club
      } label: {
        Image(systemName: "ellipsis.circle.fill")
          .font(.system(size: 22, weight: .regular))
          .foregroundStyle(.accentGreen.opacity(0.8))
      }
      
    }
    .padding(10)
    .background(.base100)
    .cornerRadius(10)
    
  }
}

#Preview {
  @Previewable @State var clubToEdit: Club? = Club(name: "", distance: 0)
  
  let testClub = Club(
    name: "7 iron",
    distance: 160
  )
  
  ClubListItem(club: testClub, clubToEdit: $clubToEdit).modelContainer(for: Club.self)
}
