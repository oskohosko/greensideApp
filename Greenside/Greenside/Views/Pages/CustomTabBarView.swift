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
  @EnvironmentObject var roundsViewModel: RoundsViewModel
  @EnvironmentObject var tabBarVisibility: TabBarVisibility
  
  @Binding var isDarkMode: Bool

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
              .environmentObject(roundsViewModel)
              .environmentObject(tabBarVisibility)
          case .play:
            PlayGolfView()
                .environmentObject(router)
          case .courses:
            CoursesView()
              .environmentObject(router)
              .environmentObject(globalViewModel)
          case .analysis:
            AnalysisView()
                .environmentObject(router)
          case .menu:
              MenuView(isDarkMode: $isDarkMode)
                .environmentObject(router)
                .environmentObject(authViewModel)

          }

        }
        // Custom Tab Bar
        if tabBarVisibility.isVisible {
          HStack {
            TabBarButton(
              icon: "house",
              selectedIcon: "house.fill",
              tab: .home,
              title: "Home",
              selectedTab: $router.tab,
              router: router
            )
            TabBarButton(
              icon: "flag.circle",
              selectedIcon: "flag.circle.fill",
              tab: .play,
              title: "Play",
              selectedTab: $router.tab,
              router: router
            )
            TabBarButton(
              icon: "mappin.circle",
              selectedIcon: "mappin.circle.fill",
              tab: .courses,
              title: "Courses",
              selectedTab: $router.tab,
              router: router
            )
            TabBarButton(
              icon: "chart.pie",
              selectedIcon: "chart.pie.fill",
              tab: .analysis,
              title: "Analysis",
              selectedTab: $router.tab,
              router: router
            )
            TabBarButton(
              icon: "text.justify",
              selectedIcon: "text.justify",
              tab: .menu,
              title: "Menu",
              selectedTab: $router.tab,
              router: router
            )
          }
          .padding(.horizontal, 10)
          .padding(.top, 20)
          .padding(.bottom, 10)
          .background(Color.base100)
        }
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
  let router: Router

  var body: some View {
    Button(action: {
      router.selectTab(tab)
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
  @Previewable @State var isDarkMode = false
  CustomTabBarView(isDarkMode: $isDarkMode)
    .environmentObject(AuthViewModel())
    .environmentObject(CoursesViewModel())
    .environmentObject(RoundsViewModel())
    .environmentObject(TabBarVisibility())
}
