//
//  SettingsView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct MenuView: View {
  @Binding var isDarkMode: Bool

  @EnvironmentObject private var router: Router
  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    NavigationStack(path: $router.menuPath) {
      ZStack {
        Color.base200.ignoresSafeArea()
        VStack(spacing: 0) {
          // Header with account info
          Button {
            router.menuNavigate(to: "account")
          } label: {
            HStack {
              Image(systemName: "figure.golf.circle.fill")
                .font(
                  .system(size: 38)
                )
                .background(
                  Circle()
                    .fill(Color.white)
                    .frame(width: 37, height: 37)
                )
                .foregroundStyle(Color.accentGreen)
              VStack(alignment: .leading, spacing: 0) {
                // User's name
                Text(
                  "\(authViewModel.user?.firstName ?? "Oskar") \(authViewModel.user?.lastName ?? "Hosken")"
                )
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.content)
                Text("See your profile")
                  .font(.system(size: 14, weight: .medium))
                  .foregroundStyle(.content)
              }
              Spacer()
            }
          }
          .padding(.horizontal)
          Divider().padding(.vertical, 12)

          // Button for lightmode/darkmode
          HStack {
            Text("Dark Mode")
              .font(.system(size: 20, weight: .medium))
              .foregroundStyle(.content)
            Spacer()
            Toggle("", isOn: $isDarkMode)
          }
          .padding(.horizontal)
          // Main content area
          VStack {
            Spacer()
            Text("Other Content Goes Here")
            Spacer()
          }
          .padding()

        }
      }
      .navigationDestination(for: String.self) { destination in
        if destination == "account" {
          AccountView()
            .environmentObject(authViewModel)
        }
      }
    }

  }
}

#Preview {
  @Previewable @State var isDarkMode = false
  MenuView(isDarkMode: $isDarkMode)
    .environmentObject(Router())
    .environmentObject(AuthViewModel())
}
