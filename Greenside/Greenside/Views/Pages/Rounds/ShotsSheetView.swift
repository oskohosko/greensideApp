//
//  ShotsSheetView.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/5/2025.
//

import SwiftUI

struct ShotsSheetView: View {
  let shots: [Shot]

  @EnvironmentObject private var sheetPosition: SheetPositionHandler

  var body: some View {
    VStack {
      HStack {
        Spacer().frame(width: 30)
        Spacer()
        VStack(spacing: 0) {
          Capsule()
            .fill(.base300)
            .frame(width: 40, height: 6)
          Text("Shots")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.content)
            .padding(.top, 4)
        }
        Spacer()
        if sheetPosition.position != .bottom {
          Button {
            sheetPosition.position = .bottom
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 24, weight: .bold))
              .foregroundStyle(.base300)
              .frame(width: 30)
          }

        } else {
          Spacer().frame(width: 30)
        }

      }
      .padding(.horizontal)
      Spacer()
    }
    .padding(.top, 12)
    .background(.base100.opacity(0.7))
    .cornerRadius(20)

  }
}

#Preview {
  ShotsSheetView(shots: []).environmentObject(SheetPositionHandler())
}
