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
  @EnvironmentObject private var coursesViewModel: CoursesViewModel
  @EnvironmentObject private var authViewModel: AuthViewModel
  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility

  var body: some View {
    NavigationStack(path: $router.homePath) {
      ZStack {
        Color.base200.ignoresSafeArea()
        VStack {
          
          // MARK: Navbar
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
            Button {
              router.navigate(to: "account")
            } label: {
              Image(systemName: "person.crop.circle")
                .font(
                  .system(size: 32)
                )
                .foregroundStyle(Color.accentGreen)
            }
          }
          .padding()
          .background(Color.base100)
          
          // MARK: Main Content
          ScrollView {
            VStack(spacing: 4) {
              Text("Play")
                .font(.system(size: 36, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.content)
                .padding(.leading, 16)
                .padding(.top, 4)

              // Now a horizontal scroll view with cards
              RoundsList()
                .environmentObject(roundsViewModel)
                .environmentObject(tabBarVisibility)
                .environmentObject(router)

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
                .padding(.top, 6)

              HStack {
                SearchBar(text: $searchText)
                  .onChange(of: searchText) {
                    coursesViewModel.filterCourses(by: searchText)
                  }
                Button {
                  coursesViewModel.sortCoursesByLocation()
                } label: {
                  Image(systemName: "location.magnifyingglass")
                    .foregroundStyle(Color(.accentGreen))
                    .font(.system(size: 32, weight: .medium))
                    .padding(.leading, 4)
                }

              }.padding(.horizontal, 16)
              CourseCardList()
                .environmentObject(coursesViewModel)
                .environmentObject(router)
              
              Text("Recent Rounds")
                .font(.system(size: 36, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.content)
                .padding(.leading, 16)
              RoundsList()
                .environmentObject(roundsViewModel)
                .environmentObject(tabBarVisibility)
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
              // Loading courses and rounds data
              _ = await coursesViewModel.loadCourses()
              await roundsViewModel.loadRounds()
            }
          }
        }
      }
      .onAppear {
        // Resetting search and sorting by closest courses
        coursesViewModel.filterCourses(by: "")
        coursesViewModel.sortCoursesByLocation()
      }
      // MARK: - Navigation destinations
      
      // Destination for the round view
      .navigationDestination(for: Round.self) { round in
        RoundDetailView(round: round)
          .environmentObject(roundsViewModel)
          .environmentObject(coursesViewModel)
          .environmentObject(tabBarVisibility)
      }
      // Destination for course view
      .navigationDestination(for: Course.self) { course in
        CourseDetailView(course: course)
          .environmentObject(coursesViewModel)
      }
      // Destination for others
      .navigationDestination(for: String.self) { destination in
        if destination == "account" {
          AccountView()
            .environmentObject(authViewModel)
        } else if destination == "addRound" {
          AddRoundView()
            .environmentObject(tabBarVisibility)
        }
      }
    }
  }
}

#Preview {
  HomeView()
    .environmentObject(CoursesViewModel())
    .environmentObject(Router())
    .environmentObject(RoundsViewModel())
    .environmentObject(AuthViewModel())
}
