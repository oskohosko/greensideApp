//
//  SettingsView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.base200.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image("Greenside")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                            Text("Greenside.")
                                .font(.title.bold())
                        }
                        Spacer()
                        Button(action: {
                            // Handle user icon tap
                        }) {
                            Image(systemName: "person.crop.circle")
                                .font(
                                    .system(size: 32)
                                )
                                .foregroundStyle(Color.primaryGreen)

                        }
                    }
                    .padding()
                    .background(Color.base100)

                    Divider()

                    // Main content area
                    VStack {
                        Spacer()
                        Text("Main Content Goes Here")
                        Spacer()
                    }
                    .padding()

                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .toolbarBackground(Color(.base100), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            }
        }
    }
}

#Preview {
    SettingsView()
}
