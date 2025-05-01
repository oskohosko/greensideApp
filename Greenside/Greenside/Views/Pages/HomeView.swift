//
//  HomeView.swift
//  Greenside
//
//  Created by Oskar Hosken on 8/4/2025.
//

import SwiftUI

struct HomeView: View {

  @State private var searchText: String = ""
  
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var viewModel: GlobalViewModel
  @EnvironmentObject private var authViewModel: AuthViewModel
  //  @State private var courses: [Course] = []

  var body: some View {
    NavigationStack {
      ZStack {
        Color.base200.ignoresSafeArea()
        VStack {
          HStack {
            HStack(spacing: 8) {
              Image("Greenside")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
              Text("Greenside.")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.content)
            }
            Spacer()
            Button(action: {
              // Handle user icon tap
              print("Logging out")
              Task {
                await authViewModel.handleLogout()
              }

            }) {
              Image(systemName: "person.crop.circle")
                .font(
                  .system(size: 32)
                )
                .foregroundStyle(Color.accentGreen)

            }
          }
          .padding()
          .background(Color.base100)

          ScrollView {
            VStack(spacing: 8) {
              Text("Play")
                .font(.system(size: 36, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.content)
                .padding(.leading, 16)
                .padding(.top, 8)

              // Now a horizontal scroll view with cards
              RoundsList()

              // Play again badge
              Badge(
                text: "Play again?",
                colour: Color((.secondary)),
                size: CGFloat(10)
              )
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 16)

              Text("Courses")
                .font(.system(size: 36, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.content)
                .padding(.leading, 16)
                .padding(.top, 10)

              HStack {
                SearchBar(text: $searchText)
                  .onChange(of: searchText) {
                    viewModel.filterCourses(by: searchText)
                  }
                Button {
                  viewModel.sortCoursesByLocation()
                } label: {
                  Image(systemName: "location.magnifyingglass")
                    .foregroundStyle(Color(.accentGreen))
                    .font(.system(size: 32, weight: .medium))
                    .padding(.leading, 4)
                }

              }.padding(.horizontal, 16)

              CourseCardList()
                .environmentObject(viewModel)
                .environmentObject(router)

            }
          }

        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbarBackground(Color(.base100), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)

        .onAppear {
          Task {
            do {
              _ = try await viewModel.loadCourses()
            } catch {
              print("Failed to load courses")
            }
          }
        }
      }
    }
  }
}

#Preview {
  HomeView().environmentObject(GlobalViewModel()).environmentObject(Router())
}
