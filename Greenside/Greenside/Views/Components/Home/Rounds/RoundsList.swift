//
//  RoundsListView.swift
//  Greenside
//
//  Created by Oskar Hosken on 18/4/2025.
//

import SwiftUI

struct RoundsList: View {

  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility
  @EnvironmentObject private var router: Router

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        AddRoundCard()
          .environmentObject(tabBarVisibility)
          .environmentObject(router)
          
          
        ForEach(roundsViewModel.allRounds) { round in
          RoundCard(round: round)
            .environmentObject(tabBarVisibility)
            .environmentObject(router)
        }

      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  RoundsList()
    .environmentObject(RoundsViewModel())
    .environmentObject(TabBarVisibility())
    .environmentObject(Router())
}
