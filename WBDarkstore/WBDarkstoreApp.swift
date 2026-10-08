//
//  WBDarkstoreApp.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 28.06.2026.
//

import SwiftUI

@main
struct WBDarkstoreApp: App {

    @State private var services = ServiceLocator()
    @State private var showLoader = true

    private let splashDuration: UInt64 = 1_500_000_000
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLoader {
                    LoaderView()
                        .transition(.opacity)
                } else if services.authService.isAuthenticated {
                    MainTabView()
                        .environment(services.router)
                        .environment(services)
                        .transition(.opacity)
                } else {
                    LoginView()
                        .environment(services.router)
                        .environment(services)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.light)
            .task {
                try? await Task.sleep(nanoseconds: splashDuration)
                withAnimation(.easeInOut(duration: 0.45)) {
                    showLoader = false
                }
            }
        }
    }
}
