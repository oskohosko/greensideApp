//
//  AuthService.swift
//  Greenside
//
//  Created by Oskar Hosken on 11/4/2025.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // Login method
    func login(email: String, password: String) async throws {
        // TODO Login
    }
    
    // Signup method
    func signup(email: String, password: String) async throws {
        // TODO Sign up
    }
    
    // Logout method
    func logout() async throws {
        // TODO Log out
    }
}
