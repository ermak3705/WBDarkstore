//
//  LoginView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 15.07.2026.
//

import SwiftUI

struct LoginView: View {
    @Environment(Router.self) private var router
    @Environment(ServiceLocator.self) private var services

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("WBDarkstore")
                .font(DSTypography.title)
                .foregroundColor(DSColors.textPrimary)

            DSCard {
                VStack(spacing: 16) {
                    DSTextField(placeholder: "Логин", text: $username)
                    DSTextField(placeholder: "Пароль", text: $password, isSecure: true)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.error)
                    }

                    DSButton(title: "Войти", isLoading: isLoading) {
                        Task {await login()}
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(DSColors.background)
    }

    private func login() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }

        do {
            try await services.authService.login(username: username, password: password)
            router.replace(with: .catalog)
        } catch {
            errorMessage = "Неверный логин или пароль"
        }
    }
}

#Preview {
    LoginView()
        .environment(Router())
        .environment(ServiceLocator())
}
