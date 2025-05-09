//
//  AddClubSheet.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//

import SwiftUI

struct AddClubSheet: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context

  @State private var name = ""
  @State private var distance = ""

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
          Text("Add Club")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.content)
          Spacer()
          Button {
            guard let metres = Int(distance),
              metres > 0,
              !name.trimmingCharacters(in: .whitespaces).isEmpty
            else { return }

            context.insert(Club(name: name, distance: metres))
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
            "",
            text: $name,
            prompt: Text("Club Name").foregroundStyle(.base500)
          )
          .foregroundStyle(.content)
          .padding()
          .background(.base100)
          .cornerRadius(14)

          TextField(
            "",
            text: $distance,
            prompt: Text("Distance").foregroundStyle(.base500)
          )
          .keyboardType(.numberPad)
          .foregroundStyle(.content)
          .padding()
          .background(.base100)
          .cornerRadius(14)

        }.padding(.horizontal)
        Spacer()

      }
      .padding(.top)
    }
  }
}

#Preview {
  AddClubSheet()
}
