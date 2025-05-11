//
//  EditClubSheet.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/5/2025.
//

import SwiftUI

struct EditClubSheet: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context

  // Club we are editing
  @Bindable var club: Club

  var body: some View {
    ZStack {
      Color(.base200).ignoresSafeArea()

      VStack(spacing: 0) {
        HStack {
          Button("Cancel", action: dismiss.callAsFunction)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.content)
            .frame(width: 70)
          Spacer()
          Text("Edit Club")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.content)
          Spacer()
          Button {
            guard club.distance > 0,
              !club.name.trimmingCharacters(in: .whitespaces).isEmpty
            else { return }

            try? context.save()
            dismiss()
          } label: {
            Text("Save")
              .font(.system(size: 20, weight: .bold))
              .foregroundStyle(.content)
              .frame(width: 70)
          }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)

        VStack {
          TextField(
            club.name,
            text: $club.name,
            prompt: Text("Club Name").foregroundStyle(.base500)
          )
          .foregroundStyle(.content)
          .padding()
          .background(.base100)
          .cornerRadius(14)

          TextField(
            "",
            value: $club.distance,
            format: .number,
            prompt: Text("Distance").foregroundStyle(.base500)
          )
          .keyboardType(.numberPad)
          .foregroundStyle(.content)
          .padding()
          .background(.base100)
          .cornerRadius(14)

        }
        .padding(.horizontal)
        .padding(.bottom)

        // Delete club button
        Button {
          // Deleting club from list
          context.delete(club)
          dismiss()
        } label: {
          Text("Delete Club")
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(.content)
            .padding(12)
            .background(.lightRed)
            .cornerRadius(20)
        }

        Spacer()

      }
      .padding(.top)
    }
  }
}

#Preview {
  let testClub = Club(
    name: "7 iron",
    distance: 160
  )

  EditClubSheet(club: testClub)
}
