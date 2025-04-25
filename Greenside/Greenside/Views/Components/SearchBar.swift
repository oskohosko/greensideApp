//
//  SearchBar.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import SwiftUI

struct SearchBar: View {

  @Binding var text: String

  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(Color(.secondary))
        .font(.system(size: 20, weight: .bold))
      ZStack(alignment: .leading) {
        if text.isEmpty {
          Text("Search...")
            .foregroundColor(.base500)
            .padding(.leading, 4)
        }
        TextField("", text: $text)
          .foregroundStyle(.content)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 8)
    .background(.base300)
    .cornerRadius(16)
    
  }

}

#Preview {
  @State var searchText = ""

  SearchBar(text: $searchText)
}
