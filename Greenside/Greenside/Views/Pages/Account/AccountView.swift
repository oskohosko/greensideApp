//
//  AccountSheet.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//

import SwiftUI

struct AccountView: View {
  // Flag to display add club sheet
  @State private var showingAddClub = false

  // Club editing
  @State private var clubToEdit: Club?

  // Collapsing list
  @State private var isClubsExpanded: Bool = false

  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      VStack {
        VStack(alignment: .leading) {
          HStack {
            Image(systemName: "figure.golf.circle.fill")
              .font(
                .system(size: 44)
              )
              .foregroundStyle(Color.accentGreen)

            VStack(alignment: .leading, spacing: 0) {
              // User's name
              Text(
                "\(authViewModel.user?.firstName ?? "Oskar") \(authViewModel.user?.lastName ?? "Hosken")"
              )
              .font(.system(size: 20, weight: .bold))
              .foregroundStyle(.content)
              // And home course
              // UPDATE THIS
              Text("Rosebud Country Club")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.content)
            }

            Spacer()
            Button {
              // Edit profile button
            } label: {
              Image(systemName: "square.and.pencil")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.content)
            }

          }
          // Add a few badges here
          Badge(
            text: "Active",
            colour: .primaryGreen,
            image: "checkmark.circle",
            size: 14
          )
        }
        .padding(.horizontal)
        .padding(.bottom, 8)

        Divider()
          .overlay(
            Rectangle()
              .frame(height: 3)
              .foregroundColor(Color.base300)
              .cornerRadius(10)
          )
          .padding(.horizontal)
          .padding(.bottom, 8)

        // Golf bag list
        HStack {
          Text("Your Bag")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.content)
          Spacer()
          // Expands and minimises list
          Button {
            withAnimation(.easeInOut) {
              isClubsExpanded.toggle()
            }
          } label: {
            Image(systemName: isClubsExpanded ? "chevron.down" : "chevron.up")
              .font(.system(size: 28, weight: .medium))
              .foregroundStyle(.content)
          }
          // Adds a club
          Button {
            showingAddClub = true
          } label: {
            Image(systemName: "plus.circle")
              .font(.system(size: 28, weight: .medium))
              .foregroundStyle(.accentGreen)
          }

        }
        .padding(.horizontal)

        ClubListView(clubToEdit: $clubToEdit, isExpanded: $isClubsExpanded)

        Spacer()
      }
    }
    .sheet(isPresented: $showingAddClub) {
      AddClubSheet()
        .presentationDetents([.fraction(0.33)])
        .presentationDragIndicator(.visible)
    }
    .sheet(item: $clubToEdit) { club in
      EditClubSheet(club: club)
        .presentationDetents([.fraction(0.33)])
        .presentationDragIndicator(.visible)
    }
  }
}

#Preview {
  AccountView().environmentObject(AuthViewModel())
}
