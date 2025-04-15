//
//  LoginView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct LoginView: View {

  enum Field: Hashable {
    case email
    case password
  }

  @StateObject private var authViewModel = AuthViewModel()
  @FocusState private var focusedField: Field?
  @State private var navigateToHome = false

  var body: some View {
    NavigationStack {
      ZStack {
        // Background colour
        Color.base200.ignoresSafeArea()
        Spacer().frame(height: 80)
        VStack {
          // Logo
          Spacer().frame(height: 24)
          Image("Greenside")
            .resizable()
            .frame(width: 72, height: 72)
          // Welcome text
          Text("Welcome back.")
            .font(
              .system(size: 28)
                .weight(.bold)
            ).foregroundStyle(Color.content)
            .padding(.top, 8)
          Spacer().frame(height: 4)
          // Description text
          Text("Please log in below to continue.")
            .font(
              .system(size: 18)
                .weight(.medium)
            ).foregroundStyle(Color.base600)

          Spacer().frame(height: 16)

          // Email text field
          Text("Email Address")
            .font(.system(size: 18).weight(.medium))
            .foregroundStyle(Color.content)
            .padding(.top, 4)
          TextField("", text: $authViewModel.email)
            .placeholder(
              show: authViewModel.email.isEmpty,
              text: "Email Address"
            )
            .focused($focusedField, equals: .email)
            .frame(height: 38)
            .frame(maxWidth: .infinity)
            .padding(.leading, 10)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentGreen, lineWidth: 2)
                .opacity(1.0)
            )
            .autocapitalization(.none)
          // Password text field
          Text("Password")
            .font(.system(size: 18).weight(.medium))
            .foregroundStyle(Color.content)
            .padding(.top, 4)
          SecureField("", text: $authViewModel.password)
            .placeholder(
              show: authViewModel.password.isEmpty,
              text: "Password"
            )
            .focused($focusedField, equals: .password)
            .frame(height: 38)
            .frame(maxWidth: .infinity)
            .padding(.leading, 10)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentGreen, lineWidth: 2)
                .opacity(1.0)
            )
            .autocapitalization(.none)
          Spacer().frame(height: 16)
          // Sign up button
          Button {
            if authViewModel.email.isEmpty {
              focusedField = .email
            } else if authViewModel.password.isEmpty {
              focusedField = .password
            } else {
              // Handling sign up action
              Task {
                await authViewModel.handleLogin(
                  email: authViewModel.email,
                  password: authViewModel.password
                )
              }
              
            }
          } label: {
            Text("Login")
              .font(.system(size: 18, weight: .medium))
              .foregroundStyle(Color.content)
              .opacity(0.8)
              .padding(10)
          }.frame(maxWidth: .infinity)
            .background(Color.accentGreen)
            .cornerRadius(16)
            .padding(.top, 12)
          // Already have an account text
          Text("Don't have an account?")
            .font(.system(size: 16).weight(.medium))
            .foregroundStyle(Color.content)
            .padding(.top, 8)
          // Navigate to login screen
          NavigationLink {
            SignUpView()
          } label: {
            Text("Sign Up")
              .font(.system(size: 18, weight: .medium))
              .foregroundStyle(Color.content)
              .opacity(0.8)
              .padding(10)
          }.frame(maxWidth: .infinity)
            .overlay(
              RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentGreen, lineWidth: 3)
                .opacity(1.0)
            )

        }.padding(.horizontal, 30)
      }
      .navigationDestination(isPresented: $navigateToHome) {
        CustomTabBarView()
      }
    }.navigationTitle("")
      .navigationBarHidden(true)
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          HStack {
            Spacer()
            Button("Done") {
              focusedField = nil
            }
          }
        }
      }
      .onAppear {
        focusedField = .email
      }
      .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
        if isLoggedIn {
          navigateToHome = true
        }
      }
  }

}

#Preview {
  LoginView()
}
