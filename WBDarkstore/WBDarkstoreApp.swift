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
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLoader {
                    LoaderView()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .environment(services.router)
                        .environment(services)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.light)
            .task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                withAnimation(.easeInOut(duration: 0.45)) {
                    showLoader = false
                }
            }
        }
    }
}
