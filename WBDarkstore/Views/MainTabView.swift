//
//  MainTabView.swift
//  WBDarkstore
//
//  Created by Илья Ермаков on 25.07.2026.
//

import SwiftUI

struct MainTabView: View {
    @Environment(ServiceLocator.self) private var services
    
    var body: some View {
        TabView {
            NavigationStack {
                CatalogView()
                    .navigationDestination(for: Category.self) { category in
                        CategoryProductsView(category: category, client: services.client)
                    }
            }
            .tabItem {
                Label("Каталог", systemImage: "square.grid.2x2")
            }
            
            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "heart")
                }
            
            CartView()
                .tabItem {
                    Label("Корзина", systemImage: "cart")
                }
        }
        .task {
            async let cart: Void = services.cartService.loadCart()
            async let favorites: Void = services.favoritesService.loadFavorites()
            _ = await (cart, favorites)
        }
    }
}

#Preview {
    MainTabView()
        .environment(ServiceLocator())
}
