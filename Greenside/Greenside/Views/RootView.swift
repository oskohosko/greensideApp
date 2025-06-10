//
//  RootView.swift
//  Greenside
//
//  Created by Oskar Hosken on 15/4/2025.
//

import SwiftUI

struct RootView: View {
  
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @EnvironmentObject var authViewModel: AuthViewModel
  @StateObject var globalViewModel = CoursesViewModel()
  @StateObject var roundsViewModel = RoundsViewModel()
  @StateObject var tabBarVisbility = TabBarVisibility()
  var body: some View {
    //    Group {
    //      switch authViewModel.phase {
    //        case .checking:
    //          LoadingView()
    //        case .authenticated:
    //          CustomTabBarView()
    //            .environmentObject(authViewModel)
    //            .environmentObject(globalViewModel)
    //            .environmentObject(roundsViewModel)
    //        default:
    //          WelcomeView()
    //      }
    //    }
    CustomTabBarView(isDarkMode: $isDarkMode)
      .environmentObject(authViewModel)
      .environmentObject(globalViewModel)
      .environmentObject(roundsViewModel)
      .environmentObject(tabBarVisbility)
      .preferredColorScheme(isDarkMode ? .dark : .light)
  }
}

#Preview {
  RootView().environmentObject(AuthViewModel())
}
