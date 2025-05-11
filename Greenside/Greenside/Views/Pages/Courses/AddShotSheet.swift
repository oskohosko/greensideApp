//
//  AddShotSheet.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/5/2025.
//

import SwiftData
import SwiftUI

// Adds a shot onto the MapView
struct AddShotSheet: View {

  @State private var golfClubs: [Club] = [
    Club(name: "Driver", distance: 230),
    Club(name: "3 Wood", distance: 215),
    Club(name: "5 Iron", distance: 180),
    Club(name: "7 Iron", distance: 160),
    Club(name: "Putter", distance: 10),
  ]

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context

  // List of clubs
  @Query(sort: \Club.distance, order: .reverse) private var clubs: [Club]

  @Binding var selectedClub: Club?

  var body: some View {
    ZStack {
      Color(.base200).opacity(0.3).ignoresSafeArea()
      VStack(alignment: .leading) {
        // Heading
        HStack {
          Text("Project Club")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.content)
          Spacer()
          Button("Cancel", action: dismiss.callAsFunction)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.content)
            .frame(width: 70)
        }
        .padding(.horizontal)
        .padding(.bottom, 1)
        .padding(.top, 16)

        Text("Select one of your clubs to project it onto the course.")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(.content)
          .padding(.bottom, 8)
          .padding(.horizontal)

        // Club list
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            if clubs.count > 0 {
              ForEach(clubs) { club in
                // Club List item
                Button {
                  // Handling club projection
                  selectedClub = club
                  dismiss()
                } label: {
                  VStack(alignment: .leading) {
                    Text(club.name)
                      .font(.system(size: 16, weight: .bold))
                      .foregroundStyle(.content)
                    HStack(spacing: 2) {
                      Image(systemName: "flag.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.accentGreen)
                      Text("\(club.distance)m")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.content)
                    }

                  }
                  .padding(12)
                  .background(Color.base100)
                  .cornerRadius(10)
                }
              }
            } else {
              ForEach(golfClubs) { club in
                // Club List item
                Button {
                  // Handling club projection
                  selectedClub = club
                  dismiss()
                } label: {
                  VStack(alignment: .leading) {
                    Text(club.name)
                      .font(.system(size: 16, weight: .bold))
                      .foregroundStyle(.content)
                    HStack(spacing: 2) {
                      Image(systemName: "flag.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.accentGreen)
                      Text("\(club.distance)m")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.content)
                    }

                  }
                  .padding(12)
                  .background(Color.base100)
                  .cornerRadius(10)
                }

              }
            }
          }.padding(.horizontal)
        }
        Spacer()
      }
    }
  }
}

#Preview {

  @Previewable @State var testClub: Club? = Club(
    name: "7 iron",
    distance: 160
  )

  AddShotSheet(selectedClub: $testClub)
}
