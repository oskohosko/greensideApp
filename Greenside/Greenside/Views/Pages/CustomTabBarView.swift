//
//  CustomTabBarView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct CustomTabBarView: View {
  @State private var selectedTab: Tab = .home
  @EnvironmentObject var authViewModel: AuthViewModel
  @StateObject var globalViewModel = GlobalViewModel()

  var body: some View {
    ZStack {
      Color(.base100).ignoresSafeArea()

      VStack(spacing: 0) {
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
              await authViewModel.logout()
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

        // Main content
        switch selectedTab {
        case .home:
          HomeView().environmentObject(globalViewModel)
        case .play:
          PlayGolfView()
        case .courses:
          CoursesView()
        case .analysis:
          AnalysisView()
        case .menu:
          MenuView()

        }

        // Custom Tab Bar
        HStack {
          TabBarButton(
            icon: "house",
            selectedIcon: "house.fill",
            tab: .home,
            title: "Home",
            selectedTab: $selectedTab
          )
          TabBarButton(
            icon: "flag.circle",
            selectedIcon: "flag.circle.fill",
            tab: .play,
            title: "Play",
            selectedTab: $selectedTab
          )
          TabBarButton(
            icon: "mappin.circle",
            selectedIcon: "mappin.circle.fill",
            tab: .courses,
            title: "Courses",
            selectedTab: $selectedTab
          )
          TabBarButton(
            icon: "chart.pie",
            selectedIcon: "chart.pie.fill",
            tab: .analysis,
            title: "Analysis",
            selectedTab: $selectedTab
          )
          TabBarButton(
            icon: "text.justify",
            selectedIcon: "text.justify",
            tab: .menu,
            title: "Menu",
            selectedTab: $selectedTab
          )
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .background(Color.base100)

      }
    }
    .onAppear {
      print("Tab bar appeared, triggering location access")
      _ = globalViewModel.locationManager.currentLocation
    }
  }
}

enum Tab {
  case home, play, courses, analysis, menu
}

struct TabBarButton: View {
  let icon: String
  let selectedIcon: String
  let tab: Tab
  let title: String
  @Binding var selectedTab: Tab

  var body: some View {
    Button(action: {
      selectedTab = tab
    }) {
      VStack(spacing: 4) {
        Image(
          systemName: selectedTab == tab ? selectedIcon : icon
        )
        .font(
          .system(
            size: (tab == .home || tab == .menu) ? 28 : 32,
            weight: .medium
          )
        )
        .foregroundColor(
          selectedTab == tab ? .accentGreen : .base400
        )
        .frame(width: 32, height: 32)

        Text(title)
          .font(
            .system(size: 12, weight: .medium)
          )
          .foregroundStyle(
            selectedTab == tab ? .primaryGreen : .base600
          )

      }
      .frame(maxWidth: .infinity)
    }
  }
}

#Preview {
  CustomTabBarView().environmentObject(AuthViewModel()).environmentObject(
    GlobalViewModel()
  )
}
