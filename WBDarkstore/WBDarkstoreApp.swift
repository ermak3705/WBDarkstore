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

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: Bindable(services.router).path) {
                LoginView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .login:
                            LoginView()
                        case .catalog:
                            CatalogView(service: services.categoryService)
                        case .categoryDetail(let category):
                            Text("Категория: \(category.name)")
                        case .profile:
                            Text("Профиль")
                        }
                    }
            }
            .environment(services.router)
            .environment(services)
        }
    }
}
