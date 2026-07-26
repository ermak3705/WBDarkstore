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
            MainTabView()
                .environment(services.router)
                .environment(services)
        }
    }
}
