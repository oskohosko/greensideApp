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

  // This is to track the drag offset when dismissing the view
  @State private var dragOffset: CGFloat = .zero

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
          // This tracks our finger
          if value.translation.height > 0 {
            dragOffset = value.translation.height
          }
        }
        .onEnded { value in
          // This is our threshold
          if value.translation.height > 200 {
            withAnimation(.easeOut(duration: 0.25)) {
              dragOffset = screenHeight
            }
            // Make sure it's off screen then dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
              dismiss()
            }
          } else {
            // Otherwise spring back if we haven't dragged far enough
            withAnimation(.spring) {
              dragOffset = .zero
            }
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
  HoleDetailFullScreen(hole: testHole).environmentObject(CoursesViewModel())
}
