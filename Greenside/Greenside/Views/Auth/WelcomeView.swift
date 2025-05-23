//
//  WelcomeView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct WelcomeView: View {

  @State private var animate = false
  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    NavigationStack {
      ZStack {
        // Background
        Color.base200.ignoresSafeArea()
        Spacer().frame(height: 100)
        VStack(spacing: 0) {
          VStack(spacing: 4) {
            ForEach(0..<3) { row in
              HStack(spacing: 4) {
                ForEach(0..<3) { col in
                  let index = row * 3 + col
                  let isPulsing = index % 2 == 1
                  ZStack {
                    RoundedRectangle(cornerRadius: 20)
                      .fill(
                        Color.accentGreen
                      )
                      .frame(width: 72, height: 72)
                      .opacity(animate ? 0.7 : 0.4)
                      .animation(
                        isPulsing
                          ? .easeInOut(duration: 1.5)
                            .repeatForever(
                              autoreverses: true
                            ) : .default,
                        value: animate
                      )
                  }
                }
              }
            }
          }
          .onAppear {
            animate = true
          }

          Spacer().frame(height: 16)
          Text("Welcome")
            .font(.system(size: 32, weight: .bold))
            .foregroundStyle(Color.content)
          Text("Please log in or sign up below.")
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(Color.content)
            .opacity(0.9)
          Spacer().frame(height: 24)
          Image("Greenside")
            .resizable()
            .frame(width: 72, height: 72)
          Spacer().frame(height: 24)
          // Navigate to login screen
          NavigationLink {
            LoginView().environmentObject(authViewModel)
          } label: {
            Text("Log in")
              .font(.system(size: 18, weight: .medium))
              .foregroundStyle(Color.content)
              .opacity(0.8)

          }.frame(maxWidth: .infinity)
            .padding()
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentGreen, lineWidth: 3)
                .opacity(1.0)
            )
          Spacer().frame(height: 16)
          // Sign in button
          NavigationLink {
            SignUpView().environmentObject(authViewModel)
          } label: {
            Text("Sign up")
              .font(.system(size: 18, weight: .medium))
              .foregroundStyle(Color.content)
              .opacity(0.8)
          }.frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentGreen)
            .cornerRadius(20)
        }
        .padding(.horizontal, 30)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onTapGesture {
          hideKeyboard()
        }
      }
    }
  }
}

#Preview {
  WelcomeView().environmentObject(AuthViewModel())
}
