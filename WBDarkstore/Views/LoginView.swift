//
//  LoginView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 15.07.2026.
//

import SwiftUI
import WBDesignSystemKit

struct LoginView: View {
    @Environment(ServiceLocator.self) private var services

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 32) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.75)

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
                                Task { await login() }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(DSColors.background)
    }

    private func login() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await services.authService.login(username: username, password: password)
            services.selectedTab = .catalog
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
