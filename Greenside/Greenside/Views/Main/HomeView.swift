//
//  HomeView.swift
//  Greenside
//
//  Created by Oskar Hosken on 8/4/2025.
//

import SwiftUI

struct HomeView: View {
  var body: some View {
    NavigationStack {
      ZStack {
        Color.base200.ignoresSafeArea()
        ScrollView {
          VStack(spacing: 8) {
            Text("Play")
              .font(.system(size: 36, weight: .bold))
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(.content)
              .padding(.leading, 16)

            // Now a horizontal scroll view with cards
            RoundsListView()
          }.padding(.top, 12)

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
  HomeView()
}
