//
//  LoadingView.swift
//  Greenside
//
//  Created by Oskar Hosken on 15/4/2025.
//

import SwiftUI

struct LoadingView: View {
  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      ProgressView("Checking login...")
        .progressViewStyle(CircularProgressViewStyle(tint: .accentGreen))
        .font(.title)
    }
  }
}

#Preview {
  LoadingView()
}
