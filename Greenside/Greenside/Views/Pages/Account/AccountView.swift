//
//  AccountSheet.swift
//  Greenside
//
//  Created by Oskar Hosken on 9/5/2025.
//

import SwiftUI

// Model for a Golf Club
struct GolfClub: Identifiable {
  let id = UUID()
  var name: String
  var distance: Int
}

struct AccountView: View {

  @State private var golfClubs: [GolfClub] = [
    GolfClub(name: "Driver", distance: 230),
    GolfClub(name: "3 Wood", distance: 215),
    GolfClub(name: "5 Iron", distance: 180),
    GolfClub(name: "7 Iron", distance: 160),
    GolfClub(name: "Putter", distance: 10),
  ]
  
  // Flag to display add club sheet
  @State private var showingAddClub = false
  
  @EnvironmentObject var authViewModel: AuthViewModel

  var body: some View {
    ZStack {
      Color.base100.ignoresSafeArea()
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
                "\(authViewModel.user?.firstName ?? "John") \(authViewModel.user?.lastName ?? "Doe")"
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
        .padding(.bottom)
        .background(.base200)

        // Golf bag list
        HStack {
          Text("Your Bag")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.content)
          Spacer()
          Button {
            showingAddClub = true
          } label: {
            Image(systemName: "plus.circle")
              .font(.system(size: 28, weight: .medium))
              .foregroundStyle(.accentGreen)
          }
          
        }
        .padding(.horizontal)
        ClubListView()

        Spacer()
      }
    }
    .sheet(isPresented: $showingAddClub, ) {
      AddClubSheet()
        .presentationDetents([.fraction(0.33)])
        .presentationDragIndicator(.visible)
    }
  }
}

#Preview {
  AccountView().environmentObject(AuthViewModel())
}
