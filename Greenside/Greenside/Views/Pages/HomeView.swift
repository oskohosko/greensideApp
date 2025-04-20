//
//  HomeView.swift
//  Greenside
//
//  Created by Oskar Hosken on 8/4/2025.
//

import SwiftUI

struct HomeView: View {

  @EnvironmentObject private var viewModel: GlobalViewModel
//  @State private var courses: [Course] = []

  var body: some View {
    NavigationStack {
      ZStack {
        Color.base200.ignoresSafeArea()
        ScrollView {
          VStack(spacing: 8) {
            Text("Play")
              .font(.system(size: 36, weight: .bold))
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(.content)
              .padding(.leading, 16)
              .padding(.top, 8)

            // Now a horizontal scroll view with cards
            RoundsList()

            // Play again badge
            Badge(
              text: "Play again?",
              colour: Color((.secondary)),
              size: CGFloat(10)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)

            Text("Courses")
              .font(.system(size: 36, weight: .bold))
              .frame(maxWidth: .infinity, alignment: .leading)
              .foregroundStyle(.content)
              .padding(.leading, 16)
              .padding(.top, 10)
            
            CourseList().environmentObject(viewModel)

          }

        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbarBackground(Color(.base100), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)

        .onAppear {
          Task {
            do {
              try await viewModel.loadCourses()
            } catch {
              print("Failed to load courses")
            }
          }

        }
      }
    }
  }
}

#Preview {
  HomeView().environmentObject(GlobalViewModel())
}
