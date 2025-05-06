//
//  RoundsListView.swift
//  Greenside
//
//  Created by Oskar Hosken on 18/4/2025.
//

import SwiftUI

struct RoundsList: View {
  
  @EnvironmentObject private var roundsViewModel: RoundsViewModel
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(roundsViewModel.allRounds) { round in
          RoundCard(round: round)
        }
      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  RoundsList()
    .environmentObject(RoundsViewModel())
    .environmentObject(Router())
}
