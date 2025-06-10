//
//  Router.swift
//  Greenside
//
//  Created by Oskar Hosken on 1/5/2025.
//

import Combine
import SwiftUI

@MainActor
final class Router: ObservableObject {
  @Published var tab: Tab = .home
  @Published var homePath = NavigationPath()
  @Published var coursesPath = NavigationPath()
  @Published var analysisPath = NavigationPath()
  @Published var menuPath = NavigationPath()
  @Published var playPath = NavigationPath()

  func selectTab(_ newTab: Tab) {
    if tab == newTab {
      resetNavigation()
    } else {
      tab = newTab
    }
  }
  
  func menuNavigate(to path: String) {
    menuPath.append(path)
  }
  
  // General home navigation
  func navigate(to path: String) {
    homePath.append(path)
  }
  
  // Navigates to round
  func navigateToRound(_ round: Round) {
    homePath.append(round)
  }
  // Function to navigate to the course path
  func navigateToCourse(_ course: Course) {
    homePath.append(course)
  }
  
  private func resetNavigation() {
    switch tab {
    case .home:
      homePath = NavigationPath()
    case .courses:
      coursesPath = NavigationPath()
    case .analysis:
      analysisPath = NavigationPath()
    case .menu:
      menuPath = NavigationPath()
    case .play:
      playPath = NavigationPath()
    }
  }
}
