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
            Text("Greenside")
              .font(.title.bold())
              .foregroundStyle(Color.content)
          }
          Spacer()
          Button(action: {
            // Handle user icon tap
            print("Logging out")
            authViewModel.logout()
            
          }) {
            Image(systemName: "person.crop.circle")
              .font(
                .system(size: 32)
              )
              .foregroundStyle(Color.primaryGreen)

          }
        }
        .padding()
        .background(Color.base100)
        Divider()
        // Main content
        switch selectedTab {
        case .home:
          HomeView()
        case .play:
          PlayGolfView()
        case .courses:
          CoursesView()
        case .analysis:
          AnalysisView()
        case .settings:
          SettingsView()
          
        }

        Divider()

        // Custom Tab Bar
        HStack(spacing: 30) {
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
            icon: "slider.horizontal.2.square",
            selectedIcon: "slider.horizontal.2.square",
            tab: .settings,
            title: "Settings",
            selectedTab: $selectedTab
          )
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(Color.base100)
      }
    }
  }
}

enum Tab {
  case home, play, courses, analysis, settings
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
      VStack {
        Image(
          systemName: selectedTab == tab ? selectedIcon : icon
        )
          .font(.system(
            size: tab == .home ? 28 : 32,
            weight: .medium))
          .foregroundColor(
            selectedTab == tab ? .primaryGreen : .base400
          )
          .frame(width: 32, height: 32)
          
          
        Spacer(minLength: 3)
        Text(title)
          .font(
            .system(size: 12, weight: .medium)
          )
          .foregroundStyle(
            selectedTab == tab ? .primaryGreen : .base600
          )

      }
      .frame(height: 32)
    }
  }
}

#Preview {
  CustomTabBarView().environmentObject(AuthViewModel())
}
