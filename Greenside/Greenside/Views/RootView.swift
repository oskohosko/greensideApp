//
//  RootView.swift
//  Greenside
//
//  Created by Oskar Hosken on 15/4/2025.
//

import SwiftUI

struct RootView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  @StateObject var globalViewModel = CoursesViewModel()
  var body: some View {
//    Group {
//      switch authViewModel.phase {
//      case .checking:
//        LoadingView()
//      case .authenticated:
//        CustomTabBarView()
//          .environmentObject(authViewModel)
//          .environmentObject(globalViewModel)
//      default:
//        WelcomeView()
//      }
//    }
    CustomTabBarView()
      .environmentObject(authViewModel)
      .environmentObject(globalViewModel)
  }
}

#Preview {
  RootView().environmentObject(AuthViewModel())
}
