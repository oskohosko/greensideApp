//
//  AnalysisView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct AnalysisView: View {
  
  @EnvironmentObject private var router: Router
  
  var body: some View {
    NavigationStack(path: $router.analysisPath) {
      ZStack {
        Color.base200.ignoresSafeArea()
        VStack(spacing: 0) {
          // Main content area
          VStack {
            Spacer()
            Text("Main Content Goes Here")
            Spacer()
          }
          .padding()

        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbarBackground(Color(.base100), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
      }
    }
  }
}

#Preview {
  AnalysisView()
    .environmentObject(Router())
}
