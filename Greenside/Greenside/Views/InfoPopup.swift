//
//  InfoPopup.swift
//  Greenside
//
//  Created by Oskar Hosken on 3/6/2025.
//

import Combine
import SwiftUI

enum PopupStyle {
  case success, error, info
}

struct PopupConfig: Identifiable {
  let id = UUID()
  var message: String
  var style: PopupStyle = .info
  var duration: TimeInterval = 2.0

  static func == (lhs: PopupConfig, rhs: PopupConfig) -> Bool {
    lhs.id == rhs.id
  }
}

// View modifier that presnets the pop-up
private struct PopupViewModifier: ViewModifier {
  @Binding var popup: PopupConfig?
  @State private var workItem: DispatchWorkItem?

  func body(content: Content) -> some View {
    ZStack(alignment: .bottom) {
      content
      if let popup = popup {
        PopupView(config: popup)
          .padding(.bottom, 16)
          .transition(.opacity.combined(with: .scale))
          .onAppear {
            fireHaptic(for: popup.style)
            armTimer(for: popup)
          }
          // If a new popup arrives before the old one dismisses, reset timer
          .onChange(of: popup.id) { _ in armTimer(for: popup) }

      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .animation(.easeInOut, value: popup != nil)
  }

  // MARK: - Helpers
  private func armTimer(for cfg: PopupConfig) {
    workItem?.cancel()
    let item = DispatchWorkItem {
      withAnimation { popup = nil }
    }
    workItem = item
    DispatchQueue.main.asyncAfter(
      deadline: .now() + cfg.duration,
      execute: item
    )
  }

  private func fireHaptic(for style: PopupStyle) {
    let generator = UINotificationFeedbackGenerator()
    switch style {
    case .success: generator.notificationOccurred(.success)
    case .error: generator.notificationOccurred(.error)
    case .info: generator.notificationOccurred(.warning)
    }
  }
}

extension View {
  func popup(_ popup: Binding<PopupConfig?>) -> some View {
    self.modifier(PopupViewModifier(popup: popup))
  }
}

// Visual representation of the popup
private struct PopupView: View {
  let config: PopupConfig

  var body: some View {
    HStack(spacing: 12) {
      Spacer()
      Image(systemName: iconName(for: config.style))
        .font(.system(size: 22, weight: .bold))
        .foregroundStyle(iconColour(for: config.style))
      Text(config.message)
        .font(.system(size: 22, weight: .medium))
        .foregroundStyle(.content)
      Spacer()
    }
    .padding()
    .background(.base100)
    .cornerRadius(15)
    .padding(6)
  }

  // Helpers
  private func iconName(for style: PopupStyle) -> String {
    switch style {
    case .success: return "checkmark.circle.fill"
    case .error: return "xmark.octagon.fill"
    case .info: return "info.circle.fill"
    }
  }

  private func iconColour(for style: PopupStyle) -> Color {
    switch style {
    case .success: return Color.lightGreen
    case .error: return Color.lightRed
    case .info: return Color.lightBlue
    }
  }
}
