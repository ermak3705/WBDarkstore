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
        @Bindable var bindableServices = services
        
        TabView(selection: $bindableServices.selectedTab) {
            NavigationStack {
                CatalogView()
                    .navigationDestination(for: Category.self) { category in
                        CategoryProductsView(category: category, client: services.client)
                    }
            }
            .tabItem {
                Label("Каталог", systemImage: "square.grid.2x2")
            }
            .tag(AppTab.catalog)
            
            FavoritesView()
                .tabItem {
                    Label("Избранное", systemImage: "heart")
                }
                .tag(AppTab.favorites)
            
            CartView()
                .tabItem {
                    Label("Корзина", systemImage: "cart")
                }
                .tag(AppTab.cart)
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
