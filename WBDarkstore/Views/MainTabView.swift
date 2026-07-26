//
//  MainTabView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 25.07.2026.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            ProductListView()
                .tabItem {
                    Label("Каталог", systemImage: "square.grid.2x2")
                }
            CartView()
                .tabItem {
                    Label("Корзина", systemImage: "cart")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environment(ServiceLocator())
}
