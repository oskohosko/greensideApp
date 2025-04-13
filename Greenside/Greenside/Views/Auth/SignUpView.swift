//
//  SignupView.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import SwiftUI

private func handleSignUp() {

}

struct SignUpView: View {

  enum Field: Hashable {
    case firstName
    case lastName
    case email
    case password
    case confirmPassword
  }

  @State private var firstName: String = ""
  @State private var lastName: String = ""
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confirmPassword: String = ""
  @FocusState private var focusedField: Field?

  var body: some View {
    NavigationStack {
      ZStack {
        // Background colour
        Color.base200.ignoresSafeArea()
        ScrollView {

          VStack {
            // Logo
            //          Spacer().frame(height: 50)
            Image("Greenside")
              .resizable()
              .frame(width: 72, height: 72)
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
            TextField("First name", text: $firstName)
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
            TextField("Last name", text: $lastName)
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
            TextField("Email Address", text: $email)
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
            SecureField("Password", text: $password)
              .focused($focusedField, equals: .password)
              .frame(height: 38)
              .padding(.leading, 10)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.accentGreen, lineWidth: 2)
                  .opacity(1.0)
              )
            // Confirm Password text field
            Text("Confirm Password")
              .font(.system(size: 18).weight(.medium))
              .foregroundStyle(Color.content)
              .padding(.top, 4)
            SecureField("Confirm password", text: $confirmPassword)
              .focused($focusedField, equals: .confirmPassword)
              .frame(height: 38)
              .padding(.leading, 10)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.accentGreen, lineWidth: 2)
                  .opacity(1.0)
              )

            // Sign up button
            Button {
              if firstName.isEmpty {
                focusedField = .firstName
              } else if lastName.isEmpty {
                focusedField = .lastName
              } else if email.isEmpty {
                focusedField = .email
              } else if password.isEmpty {
                focusedField = .password
              } else if confirmPassword.isEmpty {
                focusedField = .confirmPassword
              } else {
                // Handling sign up action
                handleSignUp()
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
              .padding(.top, 12)
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

            Spacer()
          }.padding(.horizontal, 30)

        }
      }.navigationTitle("")
        .navigationBarHidden(true)

    }
  }
}

#Preview {
  SignUpView()
}
