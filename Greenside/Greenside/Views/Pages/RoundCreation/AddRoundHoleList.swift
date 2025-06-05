//
//  AddRoundHoleList.swift
//  Greenside
//
//  Created by Oskar Hosken on 3/6/2025.
//

import SwiftUI

struct AddRoundHoleList: View {

  @EnvironmentObject private var vm: RoundCreationVM
  @EnvironmentObject private var tabBarVM: TabBarVisibility

  @Binding var mapType: MapType

  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      // If we have 18 holes I want two rows one for the front nine and one for the back
      if vm.allHoles.count == 18 {
        ForEach(0..<2) { index in
          VStack(alignment: .leading, spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 8) {
                ForEach(vm.allHoles[index * 9..<(index + 1) * 9]) {
                  hole in

                  AddRoundHoleCard(
                    hole: hole,
                    mapType: $mapType
                  )
                  .environmentObject(vm)
                  .environmentObject(tabBarVM)
                }
              }
              .padding(.horizontal)
            }
          }
        }
      } else {
        // Otherwise we show 3 rows.
        ForEach(0..<3) { index in
          let start = index * 3
          let end = min(start + 3, vm.allHoles.count)

          if start < end {
            VStack(alignment: .leading, spacing: 4) {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {

                  ForEach(vm.allHoles[start..<end]) {
                    hole in
                    AddRoundHoleCard(
                      hole: hole,
                      mapType: $mapType
                    )
                    .environmentObject(vm)
                    .environmentObject(tabBarVM)
                  }
                }
                .padding(.horizontal)
              }
            }
          }

        }
      }
    }
  }
}

#Preview {
  @Previewable @State var mapType: MapType = .standard
  AddRoundHoleList(mapType: $mapType)
    .environmentObject(RoundCreationVM())
    .environmentObject(TabBarVisibility())
}
