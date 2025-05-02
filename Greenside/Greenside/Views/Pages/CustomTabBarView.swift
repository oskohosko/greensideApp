//
//  CustomTabBarView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct CustomTabBarView: View {
  @StateObject private var router = Router()
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var globalViewModel: CoursesViewModel

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        Color(.base100).ignoresSafeArea()

        VStack(spacing: 0) {

          // Main content
          switch router.tab {
          case .home:
            HomeView()
              .environmentObject(router)
              .environmentObject(globalViewModel)
              .environmentObject(authViewModel)
          case .play:
            PlayGolfView()
          case .courses:
            CoursesView()
              .environmentObject(router)
              .environmentObject(globalViewModel)
          case .analysis:
            AnalysisView()
          case .menu:
            MenuView()

          }

        }
        // Custom Tab Bar

        HStack {
          TabBarButton(
            icon: "house",
            selectedIcon: "house.fill",
            tab: .home,
            title: "Home",
            selectedTab: $router.tab
          )
          TabBarButton(
            icon: "flag.circle",
            selectedIcon: "flag.circle.fill",
            tab: .play,
            title: "Play",
            selectedTab: $router.tab
          )
          TabBarButton(
            icon: "mappin.circle",
            selectedIcon: "mappin.circle.fill",
            tab: .courses,
            title: "Courses",
            selectedTab: $router.tab
          )
          TabBarButton(
            icon: "chart.pie",
            selectedIcon: "chart.pie.fill",
            tab: .analysis,
            title: "Analysis",
            selectedTab: $router.tab
          )
          TabBarButton(
            icon: "text.justify",
            selectedIcon: "text.justify",
            tab: .menu,
            title: "Menu",
            selectedTab: $router.tab
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
    .ignoresSafeArea(.keyboard, edges: .bottom)
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
    CoursesViewModel()
  )
}
