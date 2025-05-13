//
//  ClubListView.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//

import SwiftData
import SwiftUI

struct ClubListView: View {

  @State private var golfClubs: [Club] = [
    Club(name: "Driver", distance: 230),
    Club(name: "3 Wood", distance: 215),
    Club(name: "5 Iron", distance: 180),
    Club(name: "7 Iron", distance: 160),
    Club(name: "Putter", distance: 10),
  ]

  @Query(sort: \Club.distance, order: .reverse) private var clubs: [Club]

  @Environment(\.modelContext) private var context
  @Binding var clubToEdit: Club?
  @Binding var isExpanded: Bool

  // Collapsed height
  private var collapsedHeight: CGFloat {
    UIScreen.main.bounds.height * 0.3
  }

  var body: some View {
    // If there's no clubs
    if clubs.count == 0 {
      HStack {
        Text("No clubs added yet. Press")
          .font(.system(size: 18, weight: .medium))
          .foregroundStyle(.content)
        Image(systemName: "plus.circle")
          .font(.system(size: 18, weight: .medium))
          .foregroundStyle(.accentGreen)
        Text("to add one.")
          .font(.system(size: 18, weight: .medium))
          .foregroundStyle(.content)
      }
      .padding(10)
      .background(.base100)
      .cornerRadius(10)
    } else {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: 6) {
          ForEach(clubs) { club in
            ClubListItem(club: club, clubToEdit: $clubToEdit)
          }
        }
      }
      .padding(.horizontal)
      .frame(maxHeight: isExpanded ? .infinity : collapsedHeight)
    }
    

  }
}

#Preview {
  @Previewable @State var clubToEdit: Club? = Club(name: "", distance: 0)

  @Previewable @State var isExpanded: Bool = false

  ClubListView(clubToEdit: $clubToEdit, isExpanded: $isExpanded).modelContainer(
    for: Club.self
  )
}
