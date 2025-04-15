//
//  PlaceholderStyle.swift
//  Greenside
//
//  Created by Oskar Hosken on 13/4/2025.
//

import Foundation
import SwiftUI

struct PlaceholderStyle: ViewModifier {
  var show: Bool
  var text: String

  func body(content: Content) -> some View {
    ZStack(alignment: .leading) {
      if show {
        Text(text)
          .foregroundColor(Color.base400)
      }
      content
        .foregroundColor(Color.content)
    }
  }
}

extension View {
  func placeholder(show: Bool, text: String) -> some View {
    self.modifier(PlaceholderStyle(show: show, text: text))
  }
  
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
