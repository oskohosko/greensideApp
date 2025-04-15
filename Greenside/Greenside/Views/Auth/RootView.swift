//
//  RootView.swift
//  Greenside
//
//  Created by Oskar Hosken on 15/4/2025.
//

import SwiftUI

struct RootView: View {
  @EnvironmentObject var authViewModel: AuthViewModel
  var body: some View {
    Group {
      if authViewModel.isCheckingAuth {
        LoadingView()
          
      } else if authViewModel.isLoggedIn {
        CustomTabBarView()
          .environmentObject(authViewModel)
      } else {
        WelcomeView()
      }
    }
    .animation(.easeInOut, value: authViewModel.isLoggedIn)
    .transition(.opacity)

  }
}

#Preview {
  RootView().environmentObject(AuthViewModel())
}
