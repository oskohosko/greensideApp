//
//  HoleDetailFullScreen.swift
//  Greenside
//
//  Created by Oskar Hosken on 2/5/2025.
//

import SwiftUI

struct HoleDetailFullScreen: View {
  @Environment(\.dismiss) private var dismiss

  let hole: Hole
  
  let holeShots: [Shot]?

  // This is to track the drag offset when dismissing the view
  @State private var dragOffset: CGFloat = .zero

  @State private var dragFromTop: Bool = false

  private var screenHeight: CGFloat { UIScreen.main.bounds.height }

  var body: some View {
    NavigationStack {
      HoleDetailView(hole: hole)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { dismiss() }) {
              Image(systemName: "chevron.down")
                .font(.headline)
                .foregroundStyle(.white)
            }
          }
        }

    }
    .offset(y: dragOffset)
    .gesture(
      DragGesture()
        .onChanged { value in
          if !dragFromTop {
            dragFromTop = value.startLocation.y < 50
          }
          guard dragFromTop, value.translation.height > 0 else { return }

          dragOffset = value.translation.height
        }
        .onEnded { value in
          guard dragFromTop else { return }
          dragFromTop = false

          if value.translation.height > 200 {
            withAnimation(.easeOut(duration: 0.25)) {
              dragOffset = screenHeight
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
              dismiss()
            }
          } else {
            withAnimation(.spring) { dragOffset = .zero }
          }
        }
    )
    .interactiveDismissDisabled()
    .presentationBackground(.clear)
  }
}

#Preview {
  let testHole = Hole(
    tee_lat: -37.840217196015125,
    tee_lng: 145.09999076907312,
    green_lat: -37.8384012989252,
    green_lng: 145.100180946968,
    num: 6,
    par: 4
  )
  HoleDetailFullScreen(hole: testHole, holeShots: []).environmentObject(CoursesViewModel())
}
