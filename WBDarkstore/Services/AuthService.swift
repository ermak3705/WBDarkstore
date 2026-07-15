//
//  AuthService.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 11.07.2026.
//

import Foundation

@Observable
final class AuthService {
    private(set) var isAuthenticated = false

    func login(username: String, password: String) async throws {
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false
    }
}
