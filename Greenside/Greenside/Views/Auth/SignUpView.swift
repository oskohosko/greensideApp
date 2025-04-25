//
//  SignupView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

struct SignUpView: View {

  enum Field: Hashable {
    case firstName
    case lastName
    case email
    case password
  }

  @EnvironmentObject private var authViewModel: AuthViewModel

  @FocusState private var focusedField: Field?
  @State private var showAlert = false

  var body: some View {
    NavigationStack {
      ZStack {
        // Background colour
        Color.base200.ignoresSafeArea()
        ScrollView {

          VStack {
            // Logo

            Image("Greenside")
              .resizable()
              .frame(width: 72, height: 72)
              .padding(.top, 32)
            // Welcome text
            Text("Welcome to Greenside.")
              .font(
                .system(size: 28)
                  .weight(.bold)
              ).foregroundStyle(Color.content)
              .padding(.top, 8)
            Spacer().frame(height: 4)
            // Description text
            Text("Create an account to get started.")
              .font(
                .system(size: 18)
                  .weight(.medium)
              ).foregroundStyle(Color.base600)
            // Text fields and labels for the form

            // First name text field
            Text("First Name")
              .font(.system(size: 18).weight(.medium))
              .foregroundStyle(Color.content)
              .padding(.top, 4)
            TextField("", text: $authViewModel.firstName)
              .placeholder(
                show: authViewModel.firstName.isEmpty,
                text: "First Name"
              )
              .focused($focusedField, equals: .firstName)
              .frame(height: 38)
              .padding(.leading, 10)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.accentGreen, lineWidth: 2)
                  .opacity(1.0)
              )
            // Last name text field
            Text("Last Name")
              .font(.system(size: 18).weight(.medium))
              .foregroundStyle(Color.content)
              .padding(.top, 4)
            TextField("", text: $authViewModel.lastName)
              .placeholder(
                show: authViewModel.lastName.isEmpty,
                text: "Last Name"
              )
              .focused($focusedField, equals: .lastName)
              .frame(height: 38)
              .padding(.leading, 10)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.accentGreen, lineWidth: 2)
                  .opacity(1.0)
              )
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
              .padding(.leading, 10)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.accentGreen, lineWidth: 2)
                  .opacity(1.0)
              )
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
              .padding(.leading, 10)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.accentGreen, lineWidth: 2)
                  .opacity(1.0)
              )

            // Sign up button
            Button {
              if authViewModel.firstName.isEmpty {
                focusedField = .firstName
              } else if authViewModel.lastName.isEmpty {
                focusedField = .lastName
              } else if authViewModel.email.isEmpty {
                focusedField = .email
              } else if authViewModel.password.isEmpty {
                focusedField = .password
              } else {
                // Handling sign up action
                Task {
                  try await authViewModel.handleSignUp()
                }
              }
            } label: {
              Text("Sign Up")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.content)
                .opacity(0.8)
                .padding(10)
            }.frame(maxWidth: .infinity)
              .background(Color.accentGreen)
              .cornerRadius(16)
              .padding(.top, 32)
            // Already have an account text
            Text("Already have an account?")
              .font(.system(size: 16).weight(.medium))
              .foregroundStyle(Color.content)
              .padding(.top, 8)
            // Navigate to login screen
            NavigationLink {
              LoginView()
            } label: {
              Text("Log in")
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
          focusedField = .firstName
        }
    }
  }
}

#Preview {
  SignUpView().environmentObject(AuthViewModel())
}
