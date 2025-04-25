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
      switch authViewModel.phase {
      case .checking:
        LoadingView()
      case .authenticated:
        CustomTabBarView()
          .environmentObject(authViewModel)
      default:
        WelcomeView()
      }
    }
  }
}

#Preview {
  RootView().environmentObject(AuthViewModel())
}
